defmodule Exvend.Service.ServiceVendingMachine do
  @moduledoc false
  alias Exvend.Core.{CoinAcceptor, VendingMachine}

  def configure_coin_set(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) when is_list(coins) do
    case CoinAcceptor.invalid_coins(coin_acceptor, coins) do
      [] ->
        {:ok, coin_acceptor |> CoinAcceptor.configure_coin_set(coins) |> VendingMachine.update_coin_acceptor(machine)}
      invalid ->
        {:error, invalid, :coins, :not, :accepted}
    end
  end

#  def configure_coin_set(%__MODULE__{coin_acceptor: coin_acceptor} = machine, coins) when is_list(coins) do
#    coin_acceptor
#    |> CoinAcceptor.configure_coin_set(coins)
#    |> maybe_update_coin_acceptor(machine)
#  end
#
#  def configure_float(%__MODULE__{coin_acceptor: coin_acceptor} = machine, float) when is_list(float) do
#    coin_acceptor
#    |> CoinAcceptor.configure_float(float)
#    |> maybe_update_coin_acceptor(machine)
#  end
#
#  def create_stock_location(%__MODULE__{inventory: inventory} = machine, stock_code, price) do
#    inventory
#    |> Inventory.create_stock_location(stock_code, price)
#    |> maybe_update_inventory(machine)
#  end
#
#  def add_stock(%__MODULE__{inventory: inventory} = machine, stock_code, item) do
#    inventory
#    |> Inventory.add_stock(stock_code, item)
#    |> maybe_update_inventory(machine)
#  end
#
#  def remove_stock(%__MODULE__{inventory: inventory} = machine, stock_code, item) do
#    inventory
#    |> Inventory.remove_stock(stock_code, item)
#    |> maybe_update_inventory(machine)
#  end
#
#  defp maybe_update_inventory({:ok, updated_inventory}, machine) do
#    {:ok, %__MODULE__{machine | inventory: updated_inventory}}
#  end
#
#  defp maybe_update_inventory(error, _), do: error
end
