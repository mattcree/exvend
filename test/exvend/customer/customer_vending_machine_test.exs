defmodule CustomerVendingMachineTest do
  @moduledoc false

  use ExUnit.Case
  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory, StockLocation}
  alias Exvend.Customer.CustomerVendingMachine

  @stock_code "A1"
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

  test "should be able to vend selected product and receive change", %{machine: machine} do
  end

  test "should return error when change cannot be made" do

  end

  test "should return error when selection is invalid" do

  end

  test "should be able to insert valid coins", %{machine: machine} do
    {:ok, updated_machine} = CustomerVendingMachine.insert_coins(machine, @valid_coins)

    assert updated_machine.coin_acceptor.inserted == @valid_coins
  end

  test "should return error when invalid coin entered", %{machine: machine} do
    error = CustomerVendingMachine.insert_coins(machine, @mixed_invalid_coins)

    assert error == {:error, @invalid_coins, :coins, :not, :accepted, :returning, @mixed_invalid_coins}
  end

  test "should be able to cancel vending and receive coins" do

  end
end
