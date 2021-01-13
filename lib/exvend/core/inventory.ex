defmodule Exvend.Core.Inventory do
  @moduledoc false

  alias Exvend.Core.StockLocation

  def new do
    Map.new()
  end

  def create_stock_location(inventory, stock_code, %StockLocation{} = stock_location) do
    Map.put(inventory, stock_code, stock_location)
  end

  def get_stock_location(inventory, stock_code) do
    Map.get(inventory, stock_code)
  end

  def update_stock_location(inventory, stock_code, %StockLocation{} = stock_location) do
    Map.replace(inventory, stock_code, stock_location)
  end
end
