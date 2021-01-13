defmodule Exvend.Customer.CustomerVendingMachine do
  alias Exvend.Core.{CoinAcceptor, VendingMachine}

  @moduledoc false

  def insert_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) do
    case CoinAcceptor.invalid_coins(coin_acceptor, coins) do
      [] ->
        {:ok, VendingMachine.update_coin_acceptor(machine, CoinAcceptor.insert_coins(coin_acceptor, coins))}
      invalid ->
        {:error, invalid, :coins, :not, :accepted, :returning, coins}
    end
  end
end
