defmodule Exvend.Core.Inventory do
  @moduledoc false

  alias Exvend.Core.StockLocation

  @type stock_location :: StockLocation.stock_location()

  @typedoc """
  A stock code which references a stock location
  """
  @type stock_code :: String.t()

  @typedoc """
  The inventory which associates a stock location with a stock code
  """
  @type inventory :: map()

  @spec new :: inventory
  def new do
    Map.new()
  end

  @spec create_stock_location(inventory, stock_code, stock_location) :: inventory
  def create_stock_location(inventory, stock_code, %StockLocation{} = stock_location) do
    Map.put(inventory, stock_code, stock_location)
  end

  @spec get_stock_location(inventory, stock_code) :: stock_location | nil
  def get_stock_location(inventory, stock_code) do
    Map.get(inventory, stock_code)
  end

  @spec update_stock_location(inventory, stock_code, stock_location) :: inventory
  def update_stock_location(inventory, stock_code, %StockLocation{} = stock_location) do
    Map.replace(inventory, stock_code, stock_location)
  end
end
