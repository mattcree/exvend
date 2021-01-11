defmodule InventoryStock do
  @moduledoc false

  defstruct ~w[name price]a

  def new(name, price) do
    %__MODULE__{
      name: name,
      price: price
    }
  end
end
