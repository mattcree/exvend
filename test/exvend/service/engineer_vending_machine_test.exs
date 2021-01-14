defmodule EngineerVendingMachineTest do
  @moduledoc false

  use ExUnit.Case
  alias Exvend.Service.EngineerVendingMachine
  alias Exvend.Core.{VendingMachine, StockLocation}

  @stock_code "A1"
  @price 99
  @stock_item "Cola"
  @coin_set [1, 2, 5, 10, 20, 50, 100, 200]
  @float [1, 2, 2, 5, 5, 5, 10, 20, 20, 50, 50, 50]

  setup do
    {:ok, machine: VendingMachine.new()}
  end

  test "should be able to configure coin set", %{machine: machine} do
    {message, _} = machine |> EngineerVendingMachine.configure_coin_set(@coin_set)

    assert message == {:coin_set, MapSet.new(@coin_set)}
  end

  test "should be able to fill the float", %{machine: machine} do
    {message, _} = machine |> EngineerVendingMachine.fill_float(@float)

    assert message == {:added_to_float, @float}
  end

  test "should be able to empty the float", %{machine: machine} do
    {_, with_float} = machine |> EngineerVendingMachine.fill_float(@float)
    {message, _} = with_float |> EngineerVendingMachine.empty_float()

    assert message == {:emptied_float, @float}
  end

  test "should be able to create a new stock location", %{machine: machine} do
    {message, _} = machine |> EngineerVendingMachine.create_stock_location(@stock_code, @price)

    assert message == {:created, @stock_code}
  end

  test "should inform when stock location already exists when creating a new stock location", %{
    machine: machine
  } do
    {_, with_existing_location} =
      machine |> EngineerVendingMachine.create_stock_location(@stock_code, @price)

    {message, _} =
      with_existing_location
      |> EngineerVendingMachine.create_stock_location(@stock_code, @price)

    assert message == {:already_exists, StockLocation.new(@price)}
  end

  test "should be able to add stock", %{machine: machine} do
    {_, with_stock_location} =
      machine |> EngineerVendingMachine.create_stock_location(@stock_code, @price)

    {message, _} =
      with_stock_location |> EngineerVendingMachine.add_stock(@stock_code, @stock_item)

    assert message == {:added, @stock_item}
  end

  test "should inform when stock location does not exist when adding stock", %{machine: machine} do
    {message, _} = machine |> EngineerVendingMachine.add_stock(@stock_code, @stock_item)

    assert message == {:not_found, @stock_code}
  end

  test "should be able to remove stock", %{machine: machine} do
    {_, with_stock_location} =
      machine |> EngineerVendingMachine.create_stock_location(@stock_code, @price)

    {message, _} =
      with_stock_location |> EngineerVendingMachine.remove_stock(@stock_code, @stock_item)

    assert message == {:removed, @stock_item}
  end

  test "should inform when stock location does not exist when removing stock", %{machine: machine} do
    {message, _} = machine |> EngineerVendingMachine.remove_stock(@stock_code, @stock_item)

    assert message == {:not_found, @stock_code}
  end
end
