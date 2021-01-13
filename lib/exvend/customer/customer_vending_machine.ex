defmodule Exvend.Customer.CustomerVendingMachine do
  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory}

  @moduledoc false

  def insert_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) do
    {valid, invalid} = CoinAcceptor.sort_coins(coin_acceptor, coins)
    updated_machine = machine |> VendingMachine.update_coin_acceptor(CoinAcceptor.insert_coins(coin_acceptor, valid))
    {{:returned, invalid, :inserted, valid}, updated_machine}
  end

  def return_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine) do
    inserted = coin_acceptor.inserted
    updated_machine = machine |> VendingMachine.update_coin_acceptor(CoinAcceptor.empty_inserted_coins(coin_acceptor))
    {{:returned, inserted}, updated_machine}
  end

  def vend(%VendingMachine{inventory: inventory} = machine, stock_code, coins) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code, :returned, coins}, machine}
      stock_location ->
        {{:message}, machine}
    end
  end
end
