defmodule CoinAcceptorTest do
  @moduledoc false
  use ExUnit.Case
  alias Exvend.Core.CoinAcceptor

  @coin_set [3, 6, 5, 9]
  @coins [3]
  @float [3, 3, 3, 6, 6, 6, 5, 5, 5, 9, 9, 9]
  @valid_coins [3, 6, 5, 9]
  @invalid_coins [4, 7, 8]
  @mixed_coins @invalid_coins ++ @valid_coins

  @uk_coins [1, 2, 5, 10, 20, 50, 100, 200]

  @uk_float [1, 1, 1, 1, 2, 20, 20, 20, 50, 100]

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
    updated_coin_acceptor =
      coin_acceptor
      |> CoinAcceptor.insert_coins(@coins)
      |> CoinAcceptor.insert_coins(@coins)

    assert updated_coin_acceptor.inserted == @coins ++ @coins
  end

  test "should empty inserted coins", %{coin_acceptor: coin_acceptor} do
    updated_coin_acceptor =
      coin_acceptor |> CoinAcceptor.insert_coins(@coins) |> CoinAcceptor.empty_inserted_coins()

    assert updated_coin_acceptor.inserted == []
  end

  test "should accept coins", %{coin_acceptor: coin_acceptor} do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    updated_coin_acceptor =
      configured_coin_acceptor
      |> CoinAcceptor.fill_float(@float)
      |> CoinAcceptor.insert_coins(@coins)
      |> CoinAcceptor.accept_coins()

    assert updated_coin_acceptor.float == @float ++ @coins
  end

  test "should sort coins into valid and invalid coins based on coin set", %{
    coin_acceptor: coin_acceptor
  } do
    configured_coin_acceptor = coin_acceptor |> CoinAcceptor.configure_coin_set(@coin_set)

    {valid, invalid} = configured_coin_acceptor |> CoinAcceptor.sort_coins(@mixed_coins)

    assert valid == @valid_coins
    assert invalid == @invalid_coins
  end

  test "should calculate change", %{coin_acceptor: coin_acceptor} do
    float = [1, 1, 1, 1, 2, 20, 20, 20, 50, 100]
    result = all_possible_cashiers_change(float, 66)
    float_freq = Enum.frequencies(@uk_float)
    result2 = Enum.map(result, fn change -> {change, can_make_change(float_freq, change)} end)

    IO.inspect(result, char_lists: :as_lists)
    IO.inspect(result2, char_lists: :as_lists)

    assert result == false
  end

  def can_make_change(available_change, possible_change) do
    Map.keys(possible_change)
    |> Enum.all?(&has_enough_of_coin_in_float(available_change, possible_change, &1))
  end

  def has_enough_of_coin_in_float(available_change, possible_change, coin) do
    Map.get(available_change, coin) >= Map.get(possible_change, coin)
  end

  def all_possible_cashiers_change(coins, amount) do
    coins
    |> Enum.dedup()
    |> Enum.sort_by(&(-&1))
    |> all_possible_cashiers_change([], amount)
    |> Enum.sort_by(&length/1)
    |> Enum.map(&Enum.frequencies/1)
  end

  def all_possible_cashiers_change([], found_change, amount),
    do: found_change |> Enum.reject(&Enum.empty?/1)

  def all_possible_cashiers_change([h | t] = list, found_change, amount) do
    all_possible_cashiers_change(t, [cashiers_change(list, amount) | found_change], amount)
  end

  def cashiers_change(coins, amount), do: cashiers_change(coins, [], amount)

  defp cashiers_change(_, found_change, 0), do: found_change
  defp cashiers_change([], _, _), do: []

  defp cashiers_change([h | _] = list, found_change, remaining_amount)
       when remaining_amount >= h do
    cashiers_change(list, [h | found_change], remaining_amount - h)
  end

  defp cashiers_change([_ | t], found_change, remaining_amount) do
    cashiers_change(t, found_change, remaining_amount)
  end
end
