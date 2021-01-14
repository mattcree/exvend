defmodule Exvend.Service.CustomerVendingMachine do
  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory}

  @type vending_machine :: VendingMachine.vending_machine()
  @type coins :: CoinAcceptor.coins()
  @type stock_code :: Inventory.stock_code()
  @type vending_machine_result :: VendingMachine.vending_machine_result()

  @doc """
  Allows the customer to insert coins into the vending machine.

  Only valid coins will be accepted. Invalid coins will be rejected.

  Returns a status message including which coins were inserted and which were returned
  as well as the updated machine.

  ### Examples

  iex> machine = Exvend.Service.EngineerVendingMachine.new_machine()

  iex> {_, with_coin_set} = Exvend.Service.EngineerVendingMachine.configure_coin_set(machine, [1,3,5])

  iex> Exvend.Service.CustomerVendingMachine.insert_coins(with_coin_set,[1,2,3,4,5])
  {{:returned, [2, 4], :inserted, [1, 3, 5]},
  %Exvend.Core.VendingMachine{
   coin_acceptor: %Exvend.Core.CoinAcceptor{
     coin_set: #MapSet<[1, 3, 5]>,
     float: [],
     inserted: [1, 3, 5]
   },
   inventory: %{}
  }}
  """
  @spec insert_coins(vending_machine, coins) :: vending_machine_result
  def insert_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins) do
    {valid, invalid} = CoinAcceptor.sort_coins(coin_acceptor, coins)

    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.insert_coins(coin_acceptor, valid))

    {{:returned, invalid, :inserted, valid}, updated_machine}
  end


  @doc """
  Allows the customer to retrieve any inserted coins from the vending machine

  Returns a status message including which coins were returned as well as the updated machine.

  ### Examples

  iex> machine = Exvend.Service.EngineerVendingMachine.new_machine()

  iex> {_, with_coin_set} = Exvend.Service.EngineerVendingMachine.configure_coin_set(machine, [1,3,5])

  iex> {_, with_inserted_coins} = Exvend.Service.CustomerVendingMachine.insert_coins(with_coin_set,[1,2,3,4,5])

  iex> Exvend.Service.CustomerVendingMachine.return_coins(with_inserted_coins)
  {{:returned, [1, 3, 5]},
  %Exvend.Core.VendingMachine{
   coin_acceptor: %Exvend.Core.CoinAcceptor{
     coin_set: #MapSet<[1, 3, 5]>,
     float: [],
     inserted: []
   },
   inventory: %{}
  }}
  """
  @spec return_coins(vending_machine) :: vending_machine_result
  def return_coins(%VendingMachine{coin_acceptor: coin_acceptor} = machine) do
    inserted = coin_acceptor.inserted

    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.empty_inserted_coins(coin_acceptor))

    {{:returned, inserted}, updated_machine}
  end


  @doc """
  TBA
  """
  @spec vend(vending_machine, stock_code) :: vending_machine_result
  def vend(%VendingMachine{inventory: inventory} = machine, stock_code) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      stock_location ->
        {{:message}, machine}
    end
  end
end
