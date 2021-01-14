defmodule Exvend.Core.StockLocation do
  @moduledoc false

  @type price :: pos_integer()
  @type stock_item :: String.t()
  @type stock :: list(stock_item())

  @type t :: %__MODULE__{
               price: price(),
               stock: stock()
             }

  defstruct ~w[price stock]a

  @spec new(price) :: t
  def new(price) do
    %__MODULE__{
      price: price,
      stock: []
    }
  end

  @spec add_stock(t, stock) :: t
  def add_stock(%__MODULE__{stock: stock} = location, new_stock) do
    %__MODULE__{location | stock: [new_stock | stock]}
  end

  @spec remove_stock(t, stock) :: t
  def remove_stock(%__MODULE__{stock: stock} = location, new_stock) do
    %__MODULE__{location | stock: List.delete(stock, new_stock)}
  end
end
