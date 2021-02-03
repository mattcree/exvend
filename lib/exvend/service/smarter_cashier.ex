defmodule Exvend.Service.SmarterCashier do
  @moduledoc false

  @type target :: pos_integer
  @type coins :: list(pos_integer)

  @spec make_change(coins, target) :: coins | nil
  def make_change(coins, target) do
    minimum_set_sum(coins, target)
  end

  def minimum_set_sum(numbers, target) do
    numbers
    |> Enum.sort_by(&-&1)
    |> minimum_set_sum([], target)
  end

  def minimum_set_sum(_numbers, sum_so_far, remaining) when remaining == 0 do
    sum_so_far
  end

  def minimum_set_sum(numbers, _sum_so_far, remaining) when remaining < 0 or numbers == [] do
    nil
  end

  def minimum_set_sum([number | remaining_numbers], sum_so_far, remaining) do
    sum_with_next_number = [number | sum_so_far]

    case minimum_set_sum(remaining_numbers, sum_with_next_number, remaining - number) do
      nil -> minimum_set_sum(remaining_numbers, sum_so_far, remaining)
      set_sum -> set_sum
    end
  end
end
