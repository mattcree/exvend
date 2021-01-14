defmodule Exvend.Service.EngineerVendingMachine do
  @moduledoc false

  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory, StockLocation}

  @type vending_machine :: VendingMachine.t()
  @type coins :: CoinAcceptor.coins()
  @type stock_code :: Inventory.stock_code()
  @type stock_item :: StockLocation.stock_item()
  @type price :: StockLocation.price()
  @type vending_machine_result :: VendingMachine.vending_machine_result()

  @spec new_machine :: vending_machine
  def new_machine do
    VendingMachine.new()
  end

  @spec configure_coin_set(vending_machine, coins) :: vending_machine_result
  def configure_coin_set(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins)
      when is_list(coins) do
    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(
        CoinAcceptor.configure_coin_set(coin_acceptor, coins)
      )

    {{:coin_set, updated_machine.coin_acceptor.coin_set}, updated_machine}
  end

  @spec fill_float(vending_machine, coins) :: vending_machine_result
  def fill_float(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins)
      when is_list(coins) do
    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.fill_float(coin_acceptor, coins))

    {{:added_to_float, coins}, updated_machine}
  end

  @spec empty_float(vending_machine) :: vending_machine_result
  def empty_float(%VendingMachine{coin_acceptor: coin_acceptor} = machine) do
    float = coin_acceptor.float

    new_coin_acceptor = CoinAcceptor.empty_float(coin_acceptor)

    {{:emptied_float, float}, VendingMachine.update_coin_acceptor(machine, new_coin_acceptor)}
  end

  @spec create_stock_location(vending_machine, stock_code, price) :: vending_machine_result
  def create_stock_location(%VendingMachine{inventory: inventory} = machine, stock_code, price) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        updated_inventory =
          inventory |> Inventory.create_stock_location(stock_code, StockLocation.new(price))

        {{:created, stock_code}, VendingMachine.update_inventory(machine, updated_inventory)}

      stock_location ->
        {{:already_exists, stock_location}, machine}
    end
  end

  @spec add_stock(vending_machine, stock_code, stock_item) :: vending_machine_result
  def add_stock(%VendingMachine{inventory: inventory} = machine, stock_code, item) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      stock_location ->
        updated_stock_location = stock_location |> StockLocation.add_stock(item)

        updated_inventory =
          inventory |> Inventory.update_stock_location(stock_code, updated_stock_location)

        {{:added, item}, VendingMachine.update_inventory(machine, updated_inventory)}
    end
  end

  @spec remove_stock(vending_machine, stock_code, stock_item) :: vending_machine_result
  def remove_stock(%VendingMachine{inventory: inventory} = machine, stock_code, item) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      stock_location ->
        updated_stock_location = stock_location |> StockLocation.remove_stock(item)

        updated_inventory =
          inventory |> Inventory.update_stock_location(stock_code, updated_stock_location)

        {{:removed, item}, VendingMachine.update_inventory(machine, updated_inventory)}
    end
  end
end
