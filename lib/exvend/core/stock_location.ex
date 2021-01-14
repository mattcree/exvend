defmodule Exvend.Core.StockLocation do
  @typedoc """
  A price for a stock item
  """
  @type price :: pos_integer()

  @typedoc """
  A stock item
  """
  @type stock_item :: String.t()

  @typedoc """
  All stock which is found in a StockLocation
  """
  @type stock :: list(stock_item())

  @typedoc """
  A place in a Vending Machine which has a price, and a list of stock items for purchase
  """
  @type stock_location :: %__MODULE__{
          price: price(),
          stock: stock()
        }

  defstruct ~w[price stock]a

  @spec new(price) :: stock_location
  def new(price) do
    %__MODULE__{
      price: price,
      stock: []
    }
  end

  @spec add_stock(stock_location, stock) :: stock_location
  def add_stock(%__MODULE__{stock: stock} = location, new_stock) do
    %__MODULE__{location | stock: [new_stock | stock]}
  end

  @spec remove_stock(stock_location, stock) :: stock_location
  def remove_stock(%__MODULE__{stock: stock} = location, new_stock) do
    %__MODULE__{location | stock: List.delete(stock, new_stock)}
  end
end
