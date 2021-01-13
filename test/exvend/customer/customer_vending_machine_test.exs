defmodule CustomerVendingMachineTest do
  @moduledoc false

  use ExUnit.Case
  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory, StockLocation}
  alias Exvend.Customer.CustomerVendingMachine

  @stock_code "A1"
  @unknown_stock_code "A2"
  @stock_item "Cola"
  @coin_set [1, 2, 5, 10, 20, 50, 100, 200]
  @valid_coins [1, 2, 5, 10]
  @invalid_coins [3, 4]
  @mixed_invalid_coins @valid_coins ++ @invalid_coins

  setup do
    location = StockLocation.new(99) |> StockLocation.add_stock(@stock_item)
    coin_acceptor = CoinAcceptor.new() |> CoinAcceptor.configure_coin_set(@coin_set)
    inventory = Inventory.new() |> Inventory.create_stock_location(@stock_code, location)

    machine = VendingMachine.new()
              |> VendingMachine.update_coin_acceptor(coin_acceptor)
              |> VendingMachine.update_inventory(inventory)

    {:ok, machine: machine}
  end

  test "should insert valid coins", %{machine: machine} do
    {message, _} = machine |> CustomerVendingMachine.insert_coins(@valid_coins)

    assert message == {:returned, [], :inserted, @valid_coins}
  end

  test "should return invalid coins", %{machine: machine} do
    {message, _} = machine |> CustomerVendingMachine.insert_coins(@invalid_coins)

    assert message == {:returned, @invalid_coins, :inserted, []}
  end

  test "should return any invalid coins and insert valid coins", %{machine: machine} do
    {message, _} = machine |> CustomerVendingMachine.insert_coins(@mixed_invalid_coins)

    assert message == {:returned, [3, 4], :inserted, [1, 2, 5, 10]}
  end

  test "should be able to return inserted coins", %{machine: machine} do
    {_, with_inserted} = machine |> CustomerVendingMachine.insert_coins(@valid_coins)

    {message, _} = with_inserted |> CustomerVendingMachine.return_coins

    assert message == {:returned, @valid_coins}
  end

  test "should be able to vend selected product and receive change when vending", %{machine: machine} do

  end

  test "should inform when change cannot be made when vending" do

  end

  test "should ask for more coins when vending with too few inserted coins when vending" do

  end

  test "should inform when selected stock code not found when vending", %{machine: machine} do
    {message, _} = machine |> CustomerVendingMachine.vend(@unknown_stock_code, @valid_coins)

    assert message == {:not_found, @unknown_stock_code, :returned, @valid_coins}
  end
end
