defmodule Exvend.Service.CustomerVendingMachine do
  @moduledoc """
  The Customer facing functionality expected by a vending machine.
  Allows customers to insert and eject coins, and vend items.
  """

  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory, StockLocation}
  alias Exvend.Service.SmartCashier

  @type vending_machine :: VendingMachine.vending_machine()
  @type coins :: CoinAcceptor.coins()
  @type stock_code :: Inventory.stock_code()
  @type stock_location :: StockLocation.stock_location()
  @type vending_machine_result :: VendingMachine.vending_machine_result()

  @doc """
  Allows the customer to insert coins into the vending machine.

  Only valid coins will be accepted. Invalid coins will be rejected.

  Returns a status message including which coins were inserted and which were returned
  as well as the updated machine.

  ### Examples

  iex> machine = Exvend.Service.EngineerVendingMachine.new_machine()

  iex> {_, with_coin_set} = Exvend.Service.EngineerVendingMachine.configure_coin_set(machine, [1,3,5])

  iex> Exvend.Service.CustomerVendingMachine.insert_coins(with_coin_set,[1,2,3,4,5])
  {{:returned, [2, 4], :inserted, [1, 3, 5]},
  %Exvend.Core.VendingMachine{
   coin_acceptor: %Exvend.Core.CoinAcceptor{
     coin_set: #MapSet<[1, 3, 5]>,
     float: [],
     inserted: [1, 3, 5]
   },
   inventory: %{}
  }}
  """
  @spec insert_coins(vending_machine, coins) :: vending_machine_result
  def insert_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) do
    {valid, invalid} = CoinAcceptor.sort_coins(coin_acceptor, coins)

    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.insert_coins(coin_acceptor, valid))

    {{:returned, invalid, :inserted, valid}, updated_machine}
  end

  @doc """
  Allows the customer to retrieve any inserted coins from the vending machine

  Returns a status message including which coins were returned as well as the updated machine.

  ### Examples

  iex> machine = Exvend.Service.EngineerVendingMachine.new_machine()

  iex> {_, with_coin_set} = Exvend.Service.EngineerVendingMachine.configure_coin_set(machine, [1,3,5])

  iex> {_, with_inserted_coins} = Exvend.Service.CustomerVendingMachine.insert_coins(with_coin_set,[1,2,3,4,5])

  iex> Exvend.Service.CustomerVendingMachine.return_coins(with_inserted_coins)
  {{:returned, [1, 3, 5]},
  %Exvend.Core.VendingMachine{
   coin_acceptor: %Exvend.Core.CoinAcceptor{
     coin_set: #MapSet<[1, 3, 5]>,
     float: [],
     inserted: []
   },
   inventory: %{}
  }}
  """
  @spec return_coins(vending_machine) :: vending_machine_result
  def return_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine) do
    inserted = coin_acceptor.inserted

    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.empty_inserted_coins(coin_acceptor))

    {{:returned, inserted}, updated_machine}
  end

  @doc """
  Allows the customer to vend an item.

  The customer will be notified if
  - the item is sold out
  - the item is not found
  - they do not have enough money inserted
  - the machine doesn't have enough money to make change

  Otherwise the item and their change will be returned, along with the updated machine.

  For detailed examples please look at the unit tests.

  ### Examples


  """
  @spec vend(vending_machine, stock_code) :: vending_machine_result
  def vend(machine, stock_code) do
    case Inventory.get_stock_location(machine.inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      %StockLocation{stock: stock} when stock == [] ->
        {{:sold_out, stock_code}, machine}

      stock_location ->
        inserted_amount = Enum.sum(machine.coin_acceptor.inserted)
        available_money = machine.coin_acceptor.float ++ machine.coin_acceptor.inserted
        change_required = inserted_amount - stock_location.price

        do_vend(machine, stock_code, stock_location, available_money, change_required)
    end
  end

  @spec do_vend(vending_machine, stock_code, stock_location, coins, pos_integer) :: vending_machine_result
  defp do_vend(machine, _, _, _, change_required) when change_required < 0 do
    {{:insert_coins, abs(change_required)}, machine}
  end

  defp do_vend(machine, stock_code, location, available_money, change_required) do
    case SmartCashier.make_change(available_money, change_required) do
      nil ->
        {{:exact_change_required}, machine}

      change ->
        item = location.stock |> List.first()

        updated_coin_acceptor =
          machine.coin_acceptor
          |> CoinAcceptor.accept_coins()
          |> CoinAcceptor.remove_coins(change)

        updated_stock_location =
          location
          |> StockLocation.remove_stock(item)

        updated_inventory =
          machine.inventory
          |> Inventory.update_stock_location(stock_code, updated_stock_location)

        updated_machine =
          machine
          |> VendingMachine.update_coin_acceptor(updated_coin_acceptor)
          |> VendingMachine.update_inventory(updated_inventory)

        {{:item, item, :change, change}, updated_machine}
    end
  end
end
