defmodule ChangeTest do
  @moduledoc false

  use ExUnit.Case
  alias Exvend.Service.SmartCashier

  @coins_one [1, 1, 1, 1, 2, 20, 20, 20, 50, 100, 100]
  @return_one 66
  @target_one [1, 1, 1, 1, 2, 20, 20, 20]

  @coins_two [1, 1, 1, 1, 1, 1, 2, 2, 5, 5, 10, 20, 50, 100, 100]
  @return_two 36
  @target_two [1, 5, 10, 20]

  @coins_three [1, 1, 1, 1, 1, 1, 2, 2, 5, 50, 100, 10, 20, 20, 50]
  @return_three 36
  @target_three [1, 5, 10, 20]

  test "should calculate change 1" do
    assert SmartCashier.make_change(@coins_one, @return_one) == @target_one
  end

  test "should calculate change 2" do
    assert SmartCashier.make_change(@coins_two, @return_two) == @target_two
  end

  test "should calculate change 3" do
    assert SmartCashier.make_change(@coins_three, @return_three) == @target_three
  end
end
