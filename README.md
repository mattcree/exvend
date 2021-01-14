# Exvend

Exvend is a library which gives you all the features you'd expect from a vending machine.

You can create a new machine, configure it with a coin set, stock, and manage the float.

Then, Customers can insert their coins, vend a product, or cancel the transaction.

## Running the tests

- `$ mix test`

## Running Dialyzer for static type analysis

- `$ mix dialyzer`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exvend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exvend, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exvend](https://hexdocs.pm/exvend).

