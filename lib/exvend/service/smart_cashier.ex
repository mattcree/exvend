defmodule Exvend.Service.SmartCashier do
  @moduledoc """
  The change making service.
  """

  @type target_change :: pos_integer
  @type coins :: list(pos_integer)
  @type change_combinations :: list(coins)

  @typedoc """
  This maps a particular coin denomination to the number of times it appears
  """
  @type coin_quantities :: map()

  @doc """
  The main coin change algorithm used to compute
  change given a target number and a list of available coins

  It is adapted from the simple Cashier's Algorithm which will generate the minimal set
  of coins required to satisfy a target amount. That algorithm assumes infinite
  available coins.

  This one adapts the Cashier's Algorithm by taking into account the availability of coins in the original list.
  It essentially uses the same process but it can work with a finite group of coins.

  Essentially the process is as follows
  - Scan the list to determine what denominations we have and the quantity of each
  - For each denomination we have that is smaller than the target number ordered by largest first
    - While the current denomination is smaller than target
      - If we have enough of the coins available
        - Count it towards a possible set of change, and decrease the count for that coin's availability
        - Decrement target number by the denomination's size
      - If the coin availability is zero, move onto the next denomination
    - When the denomination is greater than the target, continue to the next denomination
      - Track this coin in 'dead end' coins and try this whole process from the top, recursively,
        removing each dead end coin from the original denominaions
    - If we find that the target is zero, we know we're finished and can return the change
    - If we find that the denominations list is empty, we know we've not found a grouping of coins that satisfies the target so we return an empty list
  - We remove empty results and sort by size (smallest first)
  - We finally take the first item from that list (it will be the change, or nil)


  Returns a list of coins which sum to the target, or nil of none can be found


  ### Examples
      iex> Exvend.Service.SmartCashier.make_change([1, 1, 1, 1, 2, 20, 20, 20], 4)
      [1, 1, 2]

      iex> Exvend.Service.SmartCashier.make_change([1, 1, 1, 1, 2, 20, 20, 20], 66)
      [1, 1, 1, 1, 2, 20, 20, 20]

      iex> Exvend.Service.SmartCashier.make_change([1, 1, 1, 1, 2, 20, 20, 20], 62)
      [2, 20, 20, 20]

      iex> Exvend.Service.SmartCashier.make_change([1, 1, 1, 1, 2, 20, 20, 20], 61)
      [1, 20, 20, 20]

      iex> Exvend.Service.SmartCashier.make_change([1, 1, 1, 1, 2, 20, 20, 20], 59)
      nil
  """
  @spec make_change(coins, target_change) :: coins | nil
  def make_change(coins, target_change) do
    coins
    |> minimum_subset_sums(target_change)
    |> Enum.sort_by(&length/1)
    |> List.first()
  end

  @spec minimum_subset_sums(coins, target_change) :: change_combinations
  def minimum_subset_sums(coins, target_change) when is_list(coins) do
    coins
    |> Enum.frequencies()
    |> minimum_subset_sums(target_change)
  end

  @spec minimum_subset_sums(coin_quantities, target_change) :: change_combinations
  def minimum_subset_sums(coin_quantities, target_change) when is_map(coin_quantities) do
    coin_quantities
    |> Map.keys()
    |> Enum.filter(&target_change >= &1)
    |> Enum.sort_by(&-&1)
    |> minimum_subset_sums(coin_quantities, target_change, [])
  end

  defp minimum_subset_sums([], _, _, all_change), do: all_change

  defp minimum_subset_sums(denominations, quantities, target, all_change) do
    case find_subset_sum(denominations, quantities, target) do
      {[], []} ->
        minimum_subset_sums(tl(denominations), quantities, target, all_change)

      {new_change, []} ->
        minimum_subset_sums(tl(denominations), quantities, target, [new_change | all_change])

      {[], dead_ends} ->
        minimum_subset_sums_without_dead_ends(dead_ends, denominations, quantities, target, all_change)

      {new_change, dead_ends} ->
        minimum_subset_sums_without_dead_ends(dead_ends, denominations, quantities, target, [new_change | all_change])
    end
  end

  defp minimum_subset_sums_without_dead_ends(dead_ends, denominations, quantities, target, all_change) do
    dead_ends
    |> Enum.reduce(all_change, &minimum_subset_sums(List.delete(denominations, &1), quantities, target, &2))
  end

  defp find_subset_sum(denominations, quantities, target) do
    find_subset_sum(denominations, quantities, target, [], [])
  end

  defp find_subset_sum([], _, _, _, dead_ends), do: {[], dead_ends}
  defp find_subset_sum(_, _, 0, change, dead_ends), do: {change, dead_ends}

  defp find_subset_sum([coin | coins] = denominations, quantities, remaining, change, dead_ends) when coin <= remaining do
    case Map.get(quantities, coin) do
      0 ->
        find_subset_sum(
          coins,
          quantities,
          remaining,
          change,
          dead_ends
        )

      quantity ->
        updated_quantities = Map.put(quantities, coin, quantity - 1)

        find_subset_sum(
          denominations,
          updated_quantities,
          remaining - coin,
          [coin | change],
          dead_ends
        )
    end
  end

  # This clause tracks coins which we have used but do not yield any change, as dead ends
  defp find_subset_sum([coin | coins], quantities, remaining, [last_coin | _] = change, dead_ends) when last_coin == coin do
    find_subset_sum(coins, quantities, remaining, change, [coin | dead_ends])
  end

  defp find_subset_sum([_ | coins], quantities, remaining, change, dead_ends) do
    find_subset_sum(coins, quantities, remaining, change, dead_ends)
  end
end
