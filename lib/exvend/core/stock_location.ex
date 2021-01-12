defmodule Exvend.Core.StockLocation do
  @moduledoc false

  defstruct ~w[stock_code price stock]a

  def new(stock_code, price) do
    %__MODULE__{
      stock_code: stock_code,
      price: price,
      stock: []
    }
  end

  def add_stock(%__MODULE__{stock: stock} = location, item) do
    %__MODULE__{location | stock: [item | stock]}
  end

  def remove_stock(%__MODULE__{stock: stock} = location, item) do
    %__MODULE__{location | stock: List.delete(stock, item)}
  end
end
