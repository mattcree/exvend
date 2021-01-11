defmodule CoinAcceptor do
  @moduledoc false

  defstruct ~w[allowed available inserted]a

  def new do
    %__MODULE__{
      allowed: MapSet.new(),
      available: [],
      inserted: []
    }
  end

  def configure_allowed(%__MODULE__{} = coins, allowed) when is_map(allowed) do
    %__MODULE__{coins | allowed: allowed}
  end

  def insert_coin(%__MODULE__{inserted: inserted} = coins, coin) when is_integer(coin) do
    %__MODULE__{coins | inserted: [coin | inserted]}
  end

  def accept_coins(%__MODULE__{available: available, inserted: inserted} = coins) do
    %__MODULE__{coins | available: available ++ inserted, inserted: []}
  end

  def is_acceptable?(%__MODULE__{allowed: allowed}, coin) when is_integer(coin) do
    MapSet.member?(allowed, coin)
  end
end
