defmodule Exvend.Customer.CustomerVendingMachine do
  alias Exvend.Core.{CoinAcceptor, VendingMachine}

  @moduledoc false

  def insert_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) do
    {valid, invalid} = CoinAcceptor.sort_coins(coin_acceptor, coins)
    updated_machine = machine |> VendingMachine.update_coin_acceptor(CoinAcceptor.insert_coins(coin_acceptor, valid))
    {{:returned, invalid, :inserted, valid}, updated_machine}
  end
end
