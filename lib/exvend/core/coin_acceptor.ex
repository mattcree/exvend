defmodule Exvend.Core.CoinAcceptor do
  @moduledoc false

  defstruct ~w[coin_set float inserted]a

  def new do
    %__MODULE__{
      coin_set: MapSet.new(),
      float: [],
      inserted: []
    }
  end

  def configure_coin_set(%__MODULE__{} = coin_acceptor, coin_set) when is_list(coin_set) do
    %__MODULE__{coin_acceptor | coin_set: MapSet.new(coin_set)}
  end

  def configure_float(%__MODULE__{} = coin_acceptor, float) when is_list(float) do
    %__MODULE__{coin_acceptor | float: float}
  end

  def insert_coins(%__MODULE__{inserted: inserted} = coin_acceptor, coins) when is_list(coins) do
    %__MODULE__{coin_acceptor | inserted: coins ++ inserted}
  end

  def accept_coins(%__MODULE__{float: float, inserted: inserted} = coin_acceptor) do
    %__MODULE__{coin_acceptor | float: float ++ inserted, inserted: []}
  end

  def invalid_coins(%__MODULE__{coin_set: coin_set}, coins) when is_list(coins) do
    MapSet.difference(MapSet.new(coins), coin_set) |> MapSet.to_list
  end
end
