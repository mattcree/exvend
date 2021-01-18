defmodule ChangeTest do
  @moduledoc false

  use ExUnit.Case
  alias Exvend.Service.SmartCashier

  @coins_one [1, 1, 1, 1, 2, 20, 20, 20, 50, 100, 100]
  @target_change_one 66
  @return_one [1, 1, 1, 1, 2, 20, 20, 20]

  @coins_two [1, 1, 1, 1, 1, 1, 2, 2, 5, 5, 10, 20, 50, 100, 100]
  @target_change_two 36
  @return_two [1, 5, 10, 20]

  @coins_three [1, 1, 1, 1, 1, 1, 2, 2, 5, 50, 100, 10, 20, 20, 50]
  @target_change_three 36
  @return_three [1, 5, 10, 20]

  @coins_four [2, 2, 3, 20]
  @target_change_four 24
  @return_four [2, 2, 20]

  test "should calculate change 1" do
    assert SmartCashier.make_change(@coins_one, @target_change_one) == @return_one
  end

  test "should calculate change 2" do
    assert SmartCashier.make_change(@coins_two, @target_change_two) == @return_two
  end

  test "should calculate change 3" do
    assert SmartCashier.make_change(@coins_three, @target_change_three) == @return_three
  end

  test "should calculate change 4" do
    assert SmartCashier.make_change(@coins_four, @target_change_four) == @return_four
  end


  #  test "should calculate possible change 1" do
#    assert SmartCashier.make_possible_change([2,2,3,20], 24) == [2, 2, 20]
#  end
#
#  test "should calculate possible change 2" do
#    assert SmartCashier.make_possible_change(@coins_two, @return_two) == @target_two
#  end
#
#  test "should calculate possible change 3" do
#    assert SmartCashier.make_possible_change(@coins_three, @return_three) == @target_three
#  end
end
