defmodule Exvend.Service.SmartCashier do


  @type target_change :: pos_integer
  @type coins :: list(pos_integer)

  @doc """
  The main coin change algorithm used to compute
  change given a target number and a list of available coins

  It is adapted from the simple Cashier's Algorithm which will generate the minimal set
  of coins required to satisfy a target amount. That algorithm assumes infinite
  available coins.

  This one adapts the Cashier's Algorithm by taking into account the availability of coins in the original list.

  Returns a list of coins which sum to the target, or nil of none can be found


  ### Examples


  """
  @spec make_change(coins, target_change) :: coins | nil
  def make_change(coins, target_amount) do
    coin_frequencies = Enum.frequencies(coins)

    change =
      coin_frequencies
      |> Map.keys
      |> Enum.filter(&(target_amount > &1))
      |> Enum.sort_by(&(-&1))
      |> find_satisfying_change(coin_frequencies, target_amount)
      |> Enum.reject(&Enum.empty?/1)
      |> Enum.sort_by(&length/1)
      |> List.first()
  end

  defp find_satisfying_change(coin_denominations, coin_frequencies, target_amount) do
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
         [coin_denomination | remaining_coins] = coin_denominations,
         coin_frequencies,
         remaining_amount,
         found_change
       )
       when remaining_amount >= coin_denomination do
    case Map.get(coin_frequencies, coin_denomination) do
      0 ->
        cashiers_change(remaining_coins, coin_frequencies, remaining_amount, found_change)

      frequency ->
        updated_coin_frequencies = Map.replace(coin_frequencies, coin_denomination, frequency - 1)

        cashiers_change(
          coin_denominations,
          updated_coin_frequencies,
          remaining_amount - coin_denomination,
          [coin_denomination | found_change]
        )
    end
  end

  defp cashiers_change([_ | t], frequencies, remaining_amount, found_change) do
    cashiers_change(t, frequencies, remaining_amount, found_change)
  end
end
