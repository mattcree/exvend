defmodule Exvend.Service.SmartCashier do
  @moduledoc """
  The subset_sum making service.
  """

  @type target :: pos_integer
  @type coins :: list(pos_integer)
  @type subset_sums :: list(coins)

  @typedoc """
  This maps a particular number denomination to the number of times it appears
  """
  @type quantities :: map()

  @doc """
  The main number subset_sum algorithm used to compute
  subset_sum given a target number and a list of available coins

  It is adapted from the simple Cashier's Algorithm which will generate the minimal set
  of coins required to satisfy a target amount. That algorithm assumes infinite
  available coins.

  This one adapts the Cashier's Algorithm by taking into account the availability of coins in the original list.
  It essentially uses the same process but it can work with a finite group of coins.

  Essentially the process is as follows
  - Scan the list to determine what numbers we have and the quantity of each
  - For each denomination we have that is smaller than the target number ordered by largest first
    - While the current denomination is smaller than target
      - If we have enough of the coins available
        - Count it towards a possible set of subset_sum, and decrease the count for that number's availability
        - Decrement target number by the denomination's size
      - If the number availability is zero, move onto the next denomination
    - When the denomination is greater than the target, continue to the next denomination
      - Track this number in 'dead end' coins and try this whole process from the top, recursively,
        removing each dead end number from the original denominaions
    - If we find that the target is zero, we know we're finished and can return the subset_sum
    - If we find that the numbers list is empty, we know we've not found a grouping of coins that satisfies the target so we return an empty list
  - We remove empty results and sort by size (smallest first)
  - We finally take the first item from that list (it will be the subset_sum, or nil)


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
  @spec make_change(coins, target) :: coins | nil
  def make_change(coins, target) do
    coins
    |> all_subset_sums(target)
    |> Enum.sort_by(&length/1)
    |> List.first()
  end

  @spec all_subset_sums(coins, target) :: subset_sums
  def all_subset_sums(coins, target) when is_list(coins) do
    coins
    |> Enum.frequencies()
    |> all_subset_sums(target)
  end

  @spec all_subset_sums(quantities, target) :: subset_sums
  def all_subset_sums(quantities, target) when is_map(quantities) do
    quantities
    |> Map.keys()
    |> Enum.filter(&target >= &1)
    |> Enum.sort_by(&-&1)
    |> all_subset_sums(quantities, target, [])
  end

  defp all_subset_sums([], _, _, subset_sums), do: subset_sums

  defp all_subset_sums(numbers, quantities, target, subset_sums) do
    case find_subset_sum(numbers, quantities, target) do
      {[], []} ->
        all_subset_sums(tl(numbers), quantities, target, subset_sums)

      {subset_sum, []} ->
        all_subset_sums(tl(numbers), quantities, target, [subset_sum | subset_sums])

      {[], dead_ends} ->
        all_subset_sums_without_dead_ends(dead_ends, numbers, quantities, target, subset_sums)

      {subset_sum, dead_ends} ->
        all_subset_sums_without_dead_ends(dead_ends, numbers, quantities, target, [subset_sum | subset_sums])
    end
  end

  defp all_subset_sums_without_dead_ends(dead_ends, numbers, quantities, target, subset_sums) do
    dead_ends
    |> Enum.reduce(subset_sums, &all_subset_sums(List.delete(numbers, &1), quantities, target, &2))
  end

  defp find_subset_sum(numbers, quantities, target) do
    find_subset_sum(numbers, quantities, target, [], [])
  end

  defp find_subset_sum([], _, _, _, dead_ends), do: {[], dead_ends}
  defp find_subset_sum(_, _, 0, subset_sum, dead_ends), do: {subset_sum, dead_ends}

  defp find_subset_sum([number | rest] = numbers, quantities, remaining, subset_sum, dead_ends) when number <= remaining do
    case Map.get(quantities, number) do
      0 ->
        find_subset_sum(
          rest,
          quantities,
          remaining,
          subset_sum,
          dead_ends
        )

      quantity ->
        updated_quantities = Map.put(quantities, number, quantity - 1)

        find_subset_sum(
          numbers,
          updated_quantities,
          remaining - number,
          [number | subset_sum],
          dead_ends
        )
    end
  end

  # This clause tracks coins which we have used but do not yield any subset sum, as dead ends
  defp find_subset_sum([next | rest], quantities, remaining, [previous | _] = subset_sum, dead_ends) when next == previous do
    find_subset_sum(rest, quantities, remaining, subset_sum, [next | dead_ends])
  end

  defp find_subset_sum([_ | rest], quantities, remaining, subset_sum, dead_ends) do
    find_subset_sum(rest, quantities, remaining, subset_sum, dead_ends)
  end
end
