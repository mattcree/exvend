defmodule Exvend.Service.SmartCashier do
  @moduledoc false

  def make_change(coins, target_amount) do
    frequencies = Enum.frequencies(coins)

    change =
      coins
      |> Enum.dedup()
      |> Enum.filter(&(target_amount > &1))
      |> Enum.sort_by(&(-&1))
      |> find_satisfying_change(frequencies, target_amount)
      |> Enum.reject(&Enum.empty?/1)
      |> Enum.sort_by(&length/1)
      |> List.first()
  end

  def find_satisfying_change(coin_denominations, coin_frequencies, target_amount) do
    find_satisfying_change(coin_denominations, coin_frequencies, target_amount, [])
  end

  defp find_satisfying_change([], _, _, change_combinations), do: change_combinations

  defp find_satisfying_change(
         coin_denominations,
         coin_frequencies,
         target_amount,
         change_combinations
       ) do
    new_change = cashiers_change(coin_denominations, coin_frequencies, target_amount)

    find_satisfying_change(
      tl(coin_denominations),
      coin_frequencies,
      target_amount,
      [new_change | change_combinations]
    )
  end

  def cashiers_change(coin_denominations, coin_frequencies, target_amount) do
    cashiers_change(coin_denominations, coin_frequencies, target_amount, [])
  end

  defp cashiers_change(_, _, 0, found_change), do: found_change
  defp cashiers_change([], _, _, _), do: []

  defp cashiers_change(
         [coin | remaining_coins] = coin_denominations,
         coin_frequencies,
         remaining_amount,
         found_change
       )
       when remaining_amount >= coin do
    case Map.get(coin_frequencies, coin) do
      0 ->
        cashiers_change(remaining_coins, coin_frequencies, remaining_amount, found_change)

      frequency ->
        updated_coin_frequencies = Map.replace(coin_frequencies, coin, frequency - 1)

        cashiers_change(
          coin_denominations,
          updated_coin_frequencies,
          remaining_amount - coin,
          [coin | found_change]
        )
    end
  end

  defp cashiers_change([_ | t], frequencies, remaining_amount, found_change) do
    cashiers_change(t, frequencies, remaining_amount, found_change)
  end
end
