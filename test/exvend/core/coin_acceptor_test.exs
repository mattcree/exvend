defmodule CoinAcceptorTest do
  @moduledoc false
  use ExUnit.Case
  alias Exvend.Core.CoinAcceptor

  @coin_set [3, 6, 5, 9]
  @coins [3]
  @float [3, 3, 3, 6, 6, 6, 5, 5, 5, 9, 9, 9]
  @valid_coins [3, 3, 6, 6, 5, 6]
  @mixed_coins [3, 4, 5, 6, 7, 8, 9]

  setup do
    {:ok, coin_acceptor: CoinAcceptor.new()}
  end

  test "should create new inventory", %{coin_acceptor: coin_acceptor} do
    assert is_map(coin_acceptor.coin_set)
    assert coin_acceptor.float == []
    assert coin_acceptor.inserted == []
  end

  test "should configure coin set", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    assert configured_coin_acceptor.coin_set == MapSet.new(@coin_set)
  end

  test "should configure float", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.fill_float(@float)

    assert configured_coin_acceptor.float == @float
  end

  test "should insert coins", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    updated_coin_acceptor = configured_coin_acceptor
                            |> CoinAcceptor.insert_coins(@coins)
                            |> CoinAcceptor.insert_coins(@coins)

    assert updated_coin_acceptor.inserted == @coins ++ @coins
  end

  test "should accept coins", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    updated_coin_acceptor = configured_coin_acceptor
            |> CoinAcceptor.fill_float(@float)
            |> CoinAcceptor.insert_coins(@coins)
            |> CoinAcceptor.accept_coins

    assert updated_coin_acceptor.float == @float ++ @coins
  end

  test "should return empty list when no invalid coins", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    invalid_coins = configured_coin_acceptor |> CoinAcceptor.invalid_coins(@mixed_coins)

    assert invalid_coins == [4, 7, 8]
  end

  test "should return invalid coins", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    invalid_coins = configured_coin_acceptor |> CoinAcceptor.invalid_coins(@valid_coins)

    assert invalid_coins == []
  end

  test "should calculate change", %{coin_acceptor: coin_acceptor} do

  end
end
