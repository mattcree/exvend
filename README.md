# Exvend

Exvend is a library which gives you all the features you'd expect from a vending machine.

You can create a new machine, configure it with a coin set, stock, and manage the float.

Then, Customers can insert their coins, vend a product, or cancel the transaction.


# Brief
This project was created to satisfy the following requirements gathered from the Faria ES technical assignment

Create a Vending Machine that should
- hold stock referenced by a code
- added and remove stock referenced by a code
- allow a user to select a product to purchase
- accept coins
- vend product when user has enough money
- return the correct change based on the available coins 
- be configurable to support different currencies

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
    - Item is sold
    - etc.
    
5. Real vending machines will accept all valid coins and return invalid coins, therefore rather than treat some invalid coins 
in a batch as as an invalid input, instead it makes sense to insert the valid coins and return the invalid coins
6. Performance, while it is a concern of this exercise, is secondary to correctness. Coin floats are the main input to the 
coin change algorithm, and should only have sizes in the thousands at most, therefore performance should be reasonable even with a naive approach.
6. When returning the smallest set of coins, the actual denominations do not matter. For example, given a coin set of `[1,2,3,4]` and a target change of `5`, it can be satisfied by `[1,4]` or `[2,3]` which are both the same size. It's assumed no particular ordering of these is important.

# Getting Started

### Get the dependencies
- `$ mix deps.get`

### Generate the documentation

- `$ mix docs`

### Run the tests

- `$ mix test`

### Run the static analysis

- `$ mix dialyzer`
- `$ mix credo`
