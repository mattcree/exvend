defmodule Exvend.Core.VendingMachine do
  @moduledoc false
  alias Exvend.Core.{CoinAcceptor, Inventory}

  defstruct ~w[coin_acceptor inventory]a

  def new() do
    %__MODULE__{
      coin_acceptor: CoinAcceptor.new(),
      inventory: Inventory.new()
    }
  end

  def update_coin_acceptor(machine, coin_acceptor) do
    %__MODULE__{machine | coin_acceptor: coin_acceptor}
  end

  def update_inventory(machine, inventory) do
    %__MODULE__{machine | inventory: inventory}
  end
end
