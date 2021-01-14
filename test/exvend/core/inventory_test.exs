defmodule InventoryTest do
  @moduledoc false
  use ExUnit.Case
  alias Exvend.Core.{Inventory, StockLocation}

  @stock_code "A1"
  @price_one 99
  @price_two 100

  setup do
    {:ok, inventory: Inventory.new(), location: StockLocation.new(@price_one)}
  end

  test "should create new inventory", %{inventory: inventory} do
    assert is_map(inventory)
  end

  test "should create stock location", %{inventory: inventory, location: location} do
    assert Map.get(inventory, @stock_code) == nil

    updated_inventory = inventory |> Inventory.create_stock_location(@stock_code, location)

    assert Map.get(updated_inventory, @stock_code) != nil
  end

  test "should get stock location", %{inventory: inventory, location: location} do
    retrieved_stock_location =
      inventory
      |> Inventory.create_stock_location(@stock_code, location)
      |> Inventory.get_stock_location(@stock_code)

    assert retrieved_stock_location == location
  end

  test "should return nil when stock location does not exist", %{inventory: inventory} do
    retrieved_stock_location = inventory |> Inventory.get_stock_location(@stock_code)

    assert retrieved_stock_location == nil
  end

  test "should update stock location when it exists", %{inventory: inventory, location: location} do
    new_location = StockLocation.new(@price_two)

    retrieved_stock_location =
      inventory
      |> Inventory.create_stock_location(@stock_code, location)
      |> Inventory.update_stock_location(@stock_code, new_location)
      |> Inventory.get_stock_location(@stock_code)

    assert retrieved_stock_location == new_location
  end
end
