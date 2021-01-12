defmodule StockLocationTest do
  @moduledoc false
  use ExUnit.Case
  alias Exvend.Core.StockLocation

  @stock_code "A2"
  @price 99

  @stock_name "Cola"

  setup do
    {:ok, stock_location: StockLocation.new(@stock_code, @price)}
  end

  test "should create new stock location", %{stock_location: stock_location} do
    assert stock_location.stock_code == @stock_code
    assert stock_location.price == @price
  end

  test "should be able to add stock", %{stock_location: stock_location} do
    assert stock_location.stock == []

    updated_stock_location = StockLocation.add_stock(stock_location, @stock_name)

    assert updated_stock_location.stock == [@stock_name]
  end

  test "should be able to remove stock", %{stock_location: stock_location} do
    with_stock = stock_location |> StockLocation.add_stock(@stock_name)

    updated_stock_location = StockLocation.remove_stock(with_stock, @stock_name)

    assert updated_stock_location.stock == []
  end

  test "should only remove one item of stock", %{stock_location: stock_location} do
    with_stock = stock_location |> StockLocation.add_stock(@stock_name) |> StockLocation.add_stock(@stock_name)

    updated_stock_location = StockLocation.remove_stock(with_stock, @stock_name)

    assert updated_stock_location.stock == [@stock_name]
  end
end
