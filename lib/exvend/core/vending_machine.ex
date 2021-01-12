defmodule Exvend.Core.VendingMachine do
  @moduledoc false

  defstruct ~w[coin_acceptor inventory]a

  def new do
    %__MODULE__{
      coin_acceptor: CoinAcceptor.new(),
      inventory: Inventory.new()
    }
  end

  def create_stock_location(%__MODULE__{inventory: inventory} = machine, stock_code, price) do
    Inventory.create_stock_location(inventory, stock_code, price) |> maybe_update_inventory(machine)
  end

  def add_stock(%__MODULE__{inventory: inventory} = machine, stock_code, item) do
    Inventory.add_stock(inventory, stock_code, item) |> maybe_update_inventory(machine)
  end

  def remove_stock(%__MODULE__{inventory: inventory} = machine, stock_code, item) do
    Inventory.remove_stock(inventory, stock_code, item) |> maybe_update_inventory(machine)
  end

  defp maybe_update_inventory({:ok, updated_inventory}, machine) do
    {:ok, %__MODULE__{machine | inventory: updated_inventory}}
  end

  defp maybe_update_inventory(error, _), do: error
end
