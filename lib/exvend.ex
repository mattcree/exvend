defmodule Exvend do
  @moduledoc """
  The public API for the Exvend Vending Machine library.

  This contains the functions which allows creation of a new machine as well as
  various interactions on the machine, including Engineer and Customer facing features.
  """

  alias Exvend.Service.{CustomerVendingMachine, EngineerVendingMachine}

  defdelegate new_machine, to: EngineerVendingMachine
  defdelegate configure_coin_set(vending_machine, coins), to: EngineerVendingMachine
  defdelegate fill_float(vending_machine, coins), to: EngineerVendingMachine
  defdelegate empty_float(vending_machine), to: EngineerVendingMachine
  defdelegate create_stock_location(vending_machine, stock_code, price), to: EngineerVendingMachine
  defdelegate add_stock(vending_machine, stock_code, stock_item), to: EngineerVendingMachine
  defdelegate remove_stock(vending_machine, stock_code, stock_item), to: EngineerVendingMachine

  defdelegate insert_coins(vending_machine, coins), to: CustomerVendingMachine
  defdelegate return_coins(vending_machine), to: CustomerVendingMachine
  defdelegate vend(vending_machine, stock_code), to: CustomerVendingMachine
end
