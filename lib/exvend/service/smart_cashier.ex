defmodule Exvend.Service.SmartCashier do
  @moduledoc """
  The change making service.
  """

  @type target_change :: pos_integer
  @type coins :: list(pos_integer)

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
    |> make_possible_change(target_change)
    |> Enum.sort_by(&length/1)
    |> List.first()
  end

  @spec make_possible_change(coins, target_change) :: list(coins)
  def make_possible_change(coins, target_change) do
    quantities = Enum.frequencies(coins)

    quantities
    |> Map.keys()
    |> Enum.filter(&(target_change >= &1))
    |> Enum.sort_by(&(-&1))
    |> satisfying_change(quantities, target_change)
    |> Enum.reject(&Enum.empty?/1)
  end

  defp satisfying_change(denominations, quantities, target) do
    satisfying_change(denominations, quantities, target, [])
  end

  defp satisfying_change([], _, _, all_change), do: all_change
  defp satisfying_change(denominations, quantities, target, all_change) do
    change = create_change(denominations, quantities, target)

    satisfying_change(tl(denominations), quantities, target, [change | all_change])
  end

  def create_change(denominations, quantities, target) do
    create_change(denominations, quantities, target, [])
  end

  defp create_change([], _, _, _), do: []
  defp create_change(_, _, 0, change), do: change

  defp create_change([coin | coins] = denominations, quantities, remaining, change)
       when remaining >= coin do

    case Map.get(quantities, coin) do
      0 ->
        create_change(coins, quantities, remaining, change)
      frequency ->
        updated_quantities = Map.put(quantities, coin, frequency - 1)
        create_change(denominations, updated_quantities, remaining - coin, [coin | change])
    end
  end

  defp create_change(denominations, quantities, remaining, change) do
    create_change(tl(denominations), quantities, remaining, change)
  end
end
