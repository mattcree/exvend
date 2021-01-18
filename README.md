# Exvend

Exvend is an Elixir library which gives you all the features you'd expect from a vending machine.

You can create a new machine, configure it with a coin set, stock, and manage the float.

Then, Customers can insert their coins, vend a product, or cancel the transaction.

# Notes on Changes

Since submitting on 18/01/2021 I recognised that the coin change algorithm has a couple of problems.

1. Mix format ruined the presentation (mainly due to my longer than idiomatic names)
2. It does not try to skip any coins inbetween coins which might yield change
   - i.e. for coins [2, 2, 3, 20] and target change of 24, it will not find it because it will attempt
     to make change with 20s, then 3s, then 2s, and cannot skip 3s.

When working with real coin denominations it is probably sufficient, but with arbitrary numbers it probably doesn't work in many cases.

I've therefore refactored the code to track dead end coins which do not yield a set of change.

Furthermore, I think this might be the wrong approach for this problem. I can't
guarantee this solves the minimum set sum problem posed by coin change, but will likely work in most cases with real coin denominations.

```elixir  
defp satisfying_change(denominations, quantities, target, all_change) do
 case create_change(denominations, quantities, target) do
   {change, []} ->
     satisfying_change(tl(denominations), quantities, target, [change | all_change])
   {change, dead_ends} ->
     dead_ends
     |> Enum.reduce(change, fn coin, extra_change ->
       denominations_without_dead_end = List.delete(denominations, coin)

       extra_change ++ satisfying_change(denominations_without_dead_end, quantities, target)
     end)
 end
end
```

The change tracking dead-ends during change making, and recursively tries to make change with those dead ends removed.

This has completely changed the likely worst case runtime dramatically.

I believe it was O(n log n) before, but potentially quadratic now unfortunately. I will probably try to optimise this in my 
own time, but suffice it to say it's not perfect :)

# Getting Started

## Requirements
This library was developed whilst using Elixir 1.10.3 and Mac OS 10.15.7.

### Get the dependencies
To install
- `$ mix deps.get`

And to view
- `$ mix deps`

### Compiling
- `$ mix compile`

### Run the tests
- `$ mix test`

### Run the static analysis

- `$ mix dialyzer`
- `$ mix credo`

# Documentation

You can generate the documentation by running
- `$ mix docs`

Then you should be able to read them at `docs/index.html`

## Exvend API
The public facing API for the project can be found in `lib/exvend.ex`

The primary return type from the public API is a tuple of the form

```elixir
{{:status_message, ...<optional-other-data>}, %VendingMachine{}}
```

Originally a composable API was considered which mainly only returned the VendingMachine type.

It became inconsistent, however, as not all functions could only return the machine. The status message portion
of the returned type will contain anything which is being returned, and ensures we always 
have the newest state of the vending machine as well as anything which should be returned.

### Exvend.new_machine/0
> This allows creation of a new Vending Machine

### Exvend.configure_coin_set/2
> Allows the Vending Machine's coin set to be configured.
> A coin set is the set of coins which the machine will accept.

### Exvend.fill_float/2
> Allows the Vending Machine's float to be configured.
> A float is the coins which are available for making change.

### Exvend.empty_float/1
> Allows the Vending Machine's float to be emptied by a Service Engineer.

### Exvend.create_stock_location/3
> Allows a new Stock Location to be added to the Vending Machine.
> A stock location is where stock is kept and is referenced by a stock code.

### Exvend.add_stock/3
> Adds a new item of stock to the Stock Location specified.

### Exvend.remove_stock/3
> Removes a new item of stock to the Stock Location specified.

### Exvend.insert_coins/2
> Allows a user to insert coins into the Vending Machine.

Returns any invalid coins in the status.


### Exvend.return_coins/1
> Allows a user to retrieve any coins inserted into the Vending Machine.

Returns any inserted coins in the status.


### Exvend.vend/1
> Allows a user vend a product when they have enough money inserted

Returns the product and change in the status.


# Brief
This project was created to satisfy the following requirements gathered from the Faria ES technical assignment

Create a Vending Machine that should
- hold stock referenced by a code
- added and remove stock referenced by a code
- allow a user to select a product to purchase using a code
- accept coins
- vend product when user has enough money
- be configurable to support different currencies

However, the core feature of the app is the algorithm is determines the change 
a Customer will receive after successfully vending a product.

The algorithm used is adapted from the Cashier's Algorithm in order to make it aware of the finite set of coins it has to work with.

It attempts to create the minimum set of coins but will limit itself only to coins which can be taken from the input list.

## Assumptions
The following assumptions were made
1. A stock location i.e. the place referenced by the code will only
   contain items which cost the same price. Therefore the stock location itself has a price, and can be stocked with any item.

2. It's required by the Engineer to fill and empty the float and necessary to prepare the machine
   for vending.

3. Prices for locations do not change (or do not need to change for this assignment)

4. Certain ordinary error cases should be handled including
   - Service engineer tries to create stock location that already exists
   - User tries to select an item that does not exist
   - The item is sold out
   - etc.

5. Real vending machines will accept all valid coins and return invalid coins, therefore rather than treat some invalid coins
   in a batch as an invalid input, instead it makes sense to insert the valid coins and return the invalid coins
6. Performance, while it is a concern of this exercise, is secondary to correctness. Coin floats are the main input to the
   coin change algorithm, and should only have sizes in the thousands at most, therefore performance should be reasonable even with a naive approach.
6. When returning the smallest set of coins, the actual denominations do not matter. For example, given a coin set of `[1,2,3,4]` and a target change of `5`, it can be satisfied by `[1,4]` or `[2,3]` which are both the same size. It's assumed no particular ordering of these is important.

## Limitations

1. Given more time I would probably refactor the `Exvend.vend/2` function since it is rather unweildy. It has many possible
paths. There is a lot of inline logic that I would probably refactor out into functions to help with readability. The documentation is not complete
for this despite it being the most important function. With more time I would have fleshed it out more, but instead directed the reader to the
unit tests which give a more clear set of conditions for each return value.

2. The Algorithm has only really been tested using the provided (from the original brief) examples and can't really be proved to work in call cases.
However, we all hope it does. It is also reasonably in need of a proper refactor for readability. I have used `mix format` which has formatted to avoid long lines.
At minimum a compromise would be to minimise the names to more abstract naming such as '[h | t]' for list pattern matching, which while not 
clean code, is a well understood convention. I opted for naming to give maximum context to the reader for this exercise, so code formatting
has suffered.

4. Testing could be a bit more focused. I have tested many lower level modules which could probably be tested via the public API.
I would like to have refactored the tests to use more fixtures so that they were not so repetitive and verbose, but they were primarily designed for 
testing correctness, considering the assignment's time constraints, rather than long term maintainability which is ordinarily a concern of mine.

5. Choosing to represent the float as a list of numbers means the algorithm is not well suited. The coin frequency map
is probably the most space efficient way to store the coins for the algorithm I presented. I'd probably rewrite the float to be a map.