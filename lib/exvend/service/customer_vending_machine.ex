defmodule Exvend.Service.CustomerVendingMachine do
  @moduledoc false

  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory}

  @type vending_machine :: VendingMachine.t()
  @type coins :: CoinAcceptor.coins()
  @type stock_code :: Inventory.stock_code()
  @type vending_machine_result :: VendingMachine.vending_machine_result()

  @spec insert_coins(vending_machine, coins) :: vending_machine_result
  def insert_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) do
    {valid, invalid} = CoinAcceptor.sort_coins(coin_acceptor, coins)

    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.insert_coins(coin_acceptor, valid))

    {{:returned, invalid, :inserted, valid}, updated_machine}
  end

  @spec return_coins(vending_machine) :: vending_machine_result
  def return_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine) do
    inserted = coin_acceptor.inserted

    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.empty_inserted_coins(coin_acceptor))

    {{:returned, inserted}, updated_machine}
  end

  @spec vend(vending_machine, stock_code) :: vending_machine_result
  def vend(%VendingMachine{inventory: inventory} = machine, stock_code) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      stock_location ->
        {{:message}, machine}
    end
  end
end
