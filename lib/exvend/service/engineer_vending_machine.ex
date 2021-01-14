defmodule Exvend.Service.EngineerVendingMachine do
  @moduledoc """
  The specific functionality required by Vending Machine Service Engineers.
  Various maintenance tasks around restocking and configuration can be found here.
  """

  alias Exvend.Core.{CoinAcceptor, VendingMachine, Inventory, StockLocation}

  @type vending_machine :: VendingMachine.vending_machine()
  @type coins :: CoinAcceptor.coins()
  @type stock_code :: Inventory.stock_code()
  @type stock_item :: StockLocation.stock_item()
  @type price :: StockLocation.price()
  @type vending_machine_result :: VendingMachine.vending_machine_result()

  @doc """
  Creates a new vending machine machine

  Returns a new vending machine.

  ## Examples
      iex> Exvend.Service.EngineerVendingMachine.new_machine
      %Exvend.Core.VendingMachine{
        coin_acceptor: %Exvend.Core.CoinAcceptor{
          coin_set: #MapSet<[]>,
          float: [],
          inserted: []
        },
        inventory: %{}
      }
  """
  @spec new_machine :: vending_machine
  def new_machine do
    VendingMachine.new()
  end

  @doc """
  Configures the coin set on an existing vending machine.

  Returns a new a status message and the updated machine.

  ## Examples
      iex> existing_machine = Exvend.Service.EngineerVendingMachine.new_machine()
      iex> Exvend.Service.EngineerVendingMachine.configure_coin_set(existing_machine, [1, 2, 5, 10, 20, 50])
      {{:coin_set, #MapSet<[1, 2, 5, 10, 20, 50]>},
        %Exvend.Core.VendingMachine{
         coin_acceptor: %Exvend.Core.CoinAcceptor{
           coin_set: #MapSet<[1, 2, 5, 10, 20, 50]>,
           float: [],
           inserted: []
         },
         inventory: %{}
      }}
  """
  @spec configure_coin_set(vending_machine, coins) :: vending_machine_result
  def configure_coin_set(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins)
      when is_list(coins) do
    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(
        CoinAcceptor.configure_coin_set(coin_acceptor, coins)
      )

    {{:coin_set, updated_machine.coin_acceptor.coin_set}, updated_machine}
  end

  @doc """

  Adds coins into the machine which will be available for change making.

  Returns a new a status message and the updated machine.

  ### Examples
      iex> existing_machine = Exvend.Service.EngineerVendingMachine.new_machine()
      iex> Exvend.Service.EngineerVendingMachine.fill_float(existing_machine, [1, 2, 3, 4, 5, 6])
      {{:added_to_float, [1, 2, 3, 4, 5, 6]},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [1, 2, 3, 4, 5, 6],
         inserted: []
       },
       inventory: %{}
      }}
  """
  @spec fill_float(vending_machine, coins) :: vending_machine_result
  def fill_float(%VendingMachine{coin_acceptor: coin_acceptor} = machine, coins)
      when is_list(coins) do
    updated_machine =
      machine
      |> VendingMachine.update_coin_acceptor(CoinAcceptor.fill_float(coin_acceptor, coins))

    {{:added_to_float, coins}, updated_machine}
  end

  @doc """

  Empties all the coins from the float and returns them with the status message.

  Returns a new a status message and the updated machine.

  ### Examples
      iex> existing_machine = Exvend.Service.EngineerVendingMachine.new_machine()
      iex> Exvend.Service.EngineerVendingMachine.fill_float(existing_machine, [1, 2, 3, 4, 5, 6])
      {{:added_to_float, [1, 2, 3, 4, 5, 6]},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [1, 2, 3, 4, 5, 6],
         inserted: []
       },
       inventory: %{}
      }}
  """
  @spec empty_float(vending_machine) :: vending_machine_result
  def empty_float(%VendingMachine{coin_acceptor: coin_acceptor} = machine) do
    float = coin_acceptor.float

    new_coin_acceptor = coin_acceptor |> CoinAcceptor.empty_float()

    {{:emptied_float, float}, VendingMachine.update_coin_acceptor(machine, new_coin_acceptor)}
  end

  @doc """

  Creates a new stock location with the specified stock code and price.

  Returns a new a status message and the updated machine if the location exists
  otherwise will return the machine with no changes.

  ### Examples
      iex> existing_machine = Exvend.Service.EngineerVendingMachine.new_machine()
      iex> Exvend.Service.EngineerVendingMachine.create_stock_location(existing_machine, "A1", 55)
      {{:created, "A1"},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [],
         inserted: []
       },
       inventory: %{"A1" => %Exvend.Core.StockLocation{price: 55, stock: []}}
      }}

  """
  @spec create_stock_location(vending_machine, stock_code, price) :: vending_machine_result
  def create_stock_location(%VendingMachine{inventory: inventory} = machine, stock_code, price) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        updated_inventory =
          inventory |> Inventory.create_stock_location(stock_code, StockLocation.new(price))

        {{:created, stock_code}, VendingMachine.update_inventory(machine, updated_inventory)}

      stock_location ->
        {{:already_exists, stock_location}, machine}
    end
  end

  @doc """

  Adds stock to the location with the specified stock code and price.

  Returns a new a status message and the updated machine if the location exists
  otherwise will return the machine with no changes. See `create_stock_location/3` for example of the error status.

  ### Examples
      iex> existing_machine = Exvend.Service.EngineerVendingMachine.new_machine()
      iex> {_, with_stock_location} = Exvend.Service.EngineerVendingMachine.create_stock_location(existing_machine, "A1", 55)
      {{:created, "A1"},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [],
         inserted: []
       },
       inventory: %{"A1" => %Exvend.Core.StockLocation{price: 55, stock: []}}
      }}
      iex> Exvend.Service.EngineerVendingMachine.add_stock(with_stock_location, "A1", "Cola")
      {{:added, "Cola"},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [],
         inserted: []
       },
       inventory: %{"A1" => %Exvend.Core.StockLocation{price: 55, stock: ["Cola"]}}
      }}
  """
  @spec add_stock(vending_machine, stock_code, stock_item) :: vending_machine_result
  def add_stock(%VendingMachine{inventory: inventory} = machine, stock_code, item) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      stock_location ->
        updated_stock_location = stock_location |> StockLocation.add_stock(item)

        updated_inventory =
          inventory |> Inventory.update_stock_location(stock_code, updated_stock_location)

        {{:added, item}, VendingMachine.update_inventory(machine, updated_inventory)}
    end
  end

  @doc """

  Adds stock to the location with the specified stock code and price.

  Returns a new a status message and the updated machine if the location exists
  otherwise will return the machine with no changes. See `create_stock_location/3` for example of the error status.

  ### Examples
      iex> existing_machine = Exvend.Service.EngineerVendingMachine.new_machine()
      iex> {_, with_stock_location} = Exvend.Service.EngineerVendingMachine.create_stock_location(existing_machine, "A1", 55)
      {{:created, "A1"},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [],
         inserted: []
       },
       inventory: %{"A1" => %Exvend.Core.StockLocation{price: 55, stock: []}}
      }}
      iex> {_, with_stock_cola}, Exvend.Service.EngineerVendingMachine.add_stock(with_stock_location, "A1", "Cola")
      {{:added, "Cola"},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [],
         inserted: []
       },
       inventory: %{"A1" => %Exvend.Core.StockLocation{price: 55, stock: ["Cola"]}}
      }}
      iex(6)> Exvend.Service.EngineerVendingMachine.remove_stock(with_stock_cola, "A1", "Cola")
      {{:removed, "Cola"},
      %Exvend.Core.VendingMachine{
       coin_acceptor: %Exvend.Core.CoinAcceptor{
         coin_set: #MapSet<[]>,
         float: [],
         inserted: []
       },
       inventory: %{"A1" => %Exvend.Core.StockLocation{price: 55, stock: []}}
      }}
  """
  @spec remove_stock(vending_machine, stock_code, stock_item) :: vending_machine_result
  def remove_stock(%VendingMachine{inventory: inventory} = machine, stock_code, item) do
    case Inventory.get_stock_location(inventory, stock_code) do
      nil ->
        {{:not_found, stock_code}, machine}

      stock_location ->
        updated_stock_location = stock_location |> StockLocation.remove_stock(item)

        updated_inventory =
          inventory |> Inventory.update_stock_location(stock_code, updated_stock_location)

        {{:removed, item}, VendingMachine.update_inventory(machine, updated_inventory)}
    end
  end
end
