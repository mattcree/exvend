defmodule Exvend.Core.CoinAcceptor do
  @moduledoc false

  @type coin_set :: map()
  @type coins :: list(pos_integer())
  @type valid_and_invalid_coins :: {coins, coins}

  @type t :: %__MODULE__{
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

  @spec configure_coin_set(t, coins) :: t
  def configure_coin_set(%__MODULE__{} = coin_acceptor, coin_set) when is_list(coin_set) do
    %__MODULE__{coin_acceptor | coin_set: MapSet.new(coin_set)}
  end

  @spec fill_float(t, coins) :: t
  def fill_float(%__MODULE__{float: float} = coin_acceptor, new_float) when is_list(float) do
    %__MODULE__{coin_acceptor | float: float ++ new_float}
  end

  @spec empty_float(t) :: t
  def empty_float(%__MODULE__{} = coin_acceptor) do
    %__MODULE__{coin_acceptor | float: []}
  end

  @spec insert_coins(t, coins) :: t
  def insert_coins(%__MODULE__{inserted: inserted} = coin_acceptor, coins) when is_list(coins) do
    %__MODULE__{coin_acceptor | inserted: coins ++ inserted}
  end

  @spec empty_inserted_coins(t) :: t
  def empty_inserted_coins(%__MODULE__{} = coin_acceptor) do
    %__MODULE__{coin_acceptor | inserted: []}
  end

  @spec accept_coins(t) :: t
  def accept_coins(%__MODULE__{float: float, inserted: inserted} = coin_acceptor) do
    %__MODULE__{coin_acceptor | float: float ++ inserted, inserted: []}
  end

  @spec sort_coins(t, coins) :: valid_and_invalid_coins
  def sort_coins(%__MODULE__{coin_set: coin_set}, coins) when is_list(coins) do
    coins |> Enum.split_with(&MapSet.member?(coin_set, &1))
  end
end
