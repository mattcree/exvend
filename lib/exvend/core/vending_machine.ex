defmodule Exvend.Core.VendingMachine do
  @moduledoc false

  alias Exvend.Core.{CoinAcceptor, Inventory}

  @type coin_acceptor :: CoinAcceptor.coin_acceptor()
  @type inventory :: Inventory.inventory()

  @type vending_machine :: %__MODULE__{
          coin_acceptor: coin_acceptor,
          inventory: inventory
        }
  @type vending_machine_message :: tuple
  @type vending_machine_result :: {vending_machine_message, vending_machine}

  defstruct ~w[coin_acceptor inventory]a

  @spec new :: vending_machine
  def new do
    %__MODULE__{
      coin_acceptor: CoinAcceptor.new(),
      inventory: Inventory.new()
    }
  end

  @spec update_coin_acceptor(vending_machine, coin_acceptor) :: vending_machine
  def update_coin_acceptor(vending_machine, coin_acceptor) do
    %__MODULE__{vending_machine | coin_acceptor: coin_acceptor}
  end

  @spec update_inventory(vending_machine, inventory) :: vending_machine
  def update_inventory(vending_machine, inventory) do
    %__MODULE__{vending_machine | inventory: inventory}
  end
end
