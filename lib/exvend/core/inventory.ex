defmodule Exvend.Core.Inventory do
  alias Exvend.Core.StockLocation
  @moduledoc false

  def new do
    Map.new()
  end

  def create_stock_location(inventory, stock_code, price) do
    case Map.get(inventory, stock_code) do
      nil ->
        Map.put(inventory, stock_code, StockLocation.new(stock_code, price))
      _ ->
        {:error, :inventory_location, stock_code, :already_exists}
    end
  end

  def add_stock(inventory, stock_code, name) do
    try do
      Map.update!(inventory, stock_code, &(StockLocation.add_stock(&1, name)))
    rescue
      KeyError -> {:error, :inventory_location, stock_code, :not_found}
    end
  end

  def remove_stock(inventory, stock_code, name) do
    try do
      Map.update!(inventory, stock_code, &(StockLocation.remove_stock(&1, name)))
    rescue
      KeyError -> {:error, :inventory_location, stock_code, :not_found}
    end
  end
end
