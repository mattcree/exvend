defmodule Exvend.Core.CoinAcceptor do
  @moduledoc false

  @typedoc """
  A set of coins representing the denominations of
  coins which are allowed for transactions
  """
  @type coin_set :: map()

  @typedoc """
  These are coins which are either taken as part of an ongoing transaction, or kept in the machine's float.
  """
  @type coins :: list(pos_integer())

  @typedoc """
  A tuple of {valid_coins, invalid_coins}. Valid coins are coins which are in the coin_set for the machine.
  """
  @type valid_and_invalid_coins :: {coins, coins}

  @typedoc """
  The coin acceptor mechanism which contains allowed coins for transactions
  as well as a float (the coins available for making change) and inserted coins
  (those which were inserted by a customer)
  """
  @type coin_acceptor :: %__MODULE__{
          coin_set: coin_set(),
          float: coins(),
          inserted: coins()
        }

  defstruct ~w[coin_set float inserted]a

  def new do
    %__MODULE__{
      coin_set: MapSet.new(),
      float: [],
      inserted: []
    }
  end

  @spec configure_coin_set(coin_acceptor, coins) :: coin_acceptor
  def configure_coin_set(%__MODULE__{} = coin_acceptor, coin_set) do
    %__MODULE__{coin_acceptor | coin_set: MapSet.new(coin_set)}
  end

  @spec fill_float(coin_acceptor, coins) :: coin_acceptor
  def fill_float(%__MODULE__{float: float} = coin_acceptor, new_float) do
    %__MODULE__{coin_acceptor | float: float ++ new_float}
  end

  @spec empty_float(coin_acceptor) :: coin_acceptor
  def empty_float(%__MODULE__{} = coin_acceptor) do
    %__MODULE__{coin_acceptor | float: []}
  end

  @spec insert_coins(coin_acceptor, coins) :: coin_acceptor
  def insert_coins(%__MODULE__{inserted: inserted} = coin_acceptor, coins) do
    %__MODULE__{coin_acceptor | inserted: coins ++ inserted}
  end

  @spec empty_inserted_coins(coin_acceptor) :: coin_acceptor
  def empty_inserted_coins(%__MODULE__{} = coin_acceptor) do
    %__MODULE__{coin_acceptor | inserted: []}
  end

  @spec accept_coins(coin_acceptor) :: coin_acceptor
  def accept_coins(%__MODULE__{float: float, inserted: inserted} = coin_acceptor) do
    %__MODULE__{coin_acceptor | float: float ++ inserted, inserted: []}
  end

  @spec remove_coins(coin_acceptor, coins) :: coin_acceptor
  def remove_coins(%__MODULE__{float: float} = coin_acceptor, coins) do
    %__MODULE__{coin_acceptor | float: float -- coins}
  end

  @spec sort_coins(coin_acceptor, coins) :: valid_and_invalid_coins
  def sort_coins(%__MODULE__{coin_set: coin_set}, coins) when is_list(coins) do
    coins |> Enum.split_with(&MapSet.member?(coin_set, &1))
  end
end
