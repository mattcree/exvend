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

  test "should insert valid coins", %{machine: machine} do
    {message, updated_machine} = machine |> CustomerVendingMachine.insert_coins(@valid_coins)

    assert message == {:returned, [], :inserted, @valid_coins}
    assert updated_machine.coin_acceptor.inserted == @valid_coins
  end

  test "should return invalid coins", %{machine: machine} do
    {message, machine} = machine |> CustomerVendingMachine.insert_coins(@invalid_coins)

    assert message == {:returned, @invalid_coins, :inserted, []}
  end

  test "should return any invalid coins and insert valid coins", %{machine: machine} do
    {message, machine} = machine |> CustomerVendingMachine.insert_coins(@mixed_invalid_coins)

    assert message == {:returned, [3, 4], :inserted, [1, 2, 5, 10]}
  end

  test "should be able to vend selected product and receive change", %{machine: machine} do

  end

  test "should be able to cancel vending and receive coins" do

  end


  test "should return error when change cannot be made" do

  end

  test "should return error when selected stock code not found" do

  end



  test "should ask for more coins when vending with too few inserted coins" do

  end

  test "should not vend when not enough change and return change" do

  end
end
