defmodule Inventory do
  @moduledoc false

  def new do
    Map.new()
  end

  def add_stock_location(stock_locations, stock_code, price) do
    case Map.get(stock_locations, stock_code) do
      nil ->
        {:ok, Map.put(stock_locations, stock_code, StockLocation.new(stock_code, price))}
      _ ->
        {:error, :stock_location, stock_code, :already_exists}
    end
  end

  def add_stock(stock_locations, stock_code, item) do
    try do
      {:ok, Map.update!(stock_locations, stock_code, &(StockLocation.add_stock(&1, item)))}
    rescue
      KeyError -> {:error, :stock_location, stock_code, :not_found}
    end
  end

  def remove_stock(stock_locations, stock_code, item) do
    try do
      {:ok, Map.update!(stock_locations, stock_code, &(StockLocation.remove_stock(&1, item)))}
    rescue
      KeyError -> {:error, :stock_location, stock_code, :not_found}
    end
  end
end
