defmodule InventoryTest do
  @moduledoc false
  use ExUnit.Case
  alias Exvend.Core.{Inventory, StockLocation}

  @stock_code "A2"
  @price 99

  setup do
    {:ok, inventory: Inventory.new()}
  end

  test "should create new inventory", %{inventory: inventory} do
    assert is_map(inventory)
  end

  test "should create stock location", %{inventory: inventory} do
    assert Map.get(inventory, @stock_code) == nil

    {:ok, updated_inventory} = inventory |> Inventory.create_stock_location(@stock_code, @price)

    assert Map.get(updated_inventory, @stock_code) != nil
  end

  test "should return error when creating stock location that exists", %{inventory: inventory} do
    assert Map.get(inventory, @stock_code) == nil

    {_, updated_inventory} = inventory |> Inventory.create_stock_location(@stock_code, @price)
    error = updated_inventory |> Inventory.create_stock_location(@stock_code, @price)

    assert error == {:error, :inventory_location, @stock_code, :already_exists}
  end

  test "should add stock", %{inventory: inventory} do
    {_, updated_inventory} = inventory |> Inventory.create_stock_location(@stock_code, @price)

  end

  test "should return error when adding stock to stock location that does not exist", %{inventory: inventory} do

  end
end
