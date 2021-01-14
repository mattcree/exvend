defmodule Exvend.Core.Inventory do
  @moduledoc false

  alias Exvend.Core.StockLocation

  @type stock_location :: StockLocation.t()
  @type stock_code :: String.t()
  @type t :: map()

  @spec new :: t
  def new do
    Map.new()
  end

  @spec create_stock_location(t, stock_code, stock_location) :: t
  def create_stock_location(inventory, stock_code, %StockLocation{} = stock_location) do
    Map.put(inventory, stock_code, stock_location)
  end

  @spec get_stock_location(t, stock_code) :: t | nil
  def get_stock_location(inventory, stock_code) do
    Map.get(inventory, stock_code)
  end

  @spec update_stock_location(t, stock_code, stock_location) :: t
  def update_stock_location(inventory, stock_code, %StockLocation{} = stock_location) do
    Map.replace(inventory, stock_code, stock_location)
  end
end
