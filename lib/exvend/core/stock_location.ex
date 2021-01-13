defmodule Exvend.Core.StockLocation do
  @moduledoc false

  defstruct ~w[price stock]a

  def new(price) do
    %__MODULE__{
      price: price,
      stock: []
    }
  end

  def add_stock(%__MODULE__{stock: stock} = location, new_stock) do
    %__MODULE__{location | stock: [new_stock | stock]}
  end

  def remove_stock(%__MODULE__{stock: stock} = location, new_stock) do
    %__MODULE__{location | stock: List.delete(stock, new_stock)}
  end

  def update_price(%__MODULE__{} = location, price) do
    %__MODULE__{location | price: price}
  end
end
