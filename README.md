# CartServer

Minimal Elixir GenServer that models a shopping cart and demonstrates common GenServer patterns:
state initialization, synchronous `call`, asynchronous `cast`, timers with `handle_info/2`, and
client-facing wrapper functions.

## Requirements
- Elixir 1.15+

## Getting Started
```bash
git clone <this repo>
cd cart_server
mix deps.get
iex -S mix
```

Start the server and interact with it from `iex`:
```elixir
# Boot the GenServer under the name :cart_server
{:ok, _pid} = CartServer.start_link()
```

## Public API
All client functions delegate to the GenServer named `:cart_server`.

- `CartServer.add_item(%{name: "Apples", price: 2, qty: 3})`  
  Adds an item asynchronously. Items are stored in the cart list.

- `CartServer.cart_total()`  
  Synchronously returns the total cost by summing `price * qty` for each item.

- `CartServer.find_item("Apples")`  
  Synchronously retrieves the first item whose `:name` matches.

## Timer-based reminder
Every time you add an item, the server (re)starts a 5-second timer. When it fires, `handle_info/2`
prints `Don't forget to check out your cart!`. Adding another item cancels the previous timer so
only the most recent reminder will run.

## Example Session
```elixir
{:ok, _pid} = CartServer.start_link()

CartServer.add_item(%{name: "Milk", price: 150, qty: 1})
CartServer.add_item(%{name: "Bread", price: 80, qty: 2})

CartServer.cart_total()
# => 310

CartServer.find_item("Bread")
# => %{name: "Bread", price: 80, qty: 2}

# After 5 seconds (reset on each add_item)
# => Don't forget to check out your cart!
```

## Notes
- The server is started manually via `CartServer.start_link/0`; it is not added to a supervision
  tree in this demo.
- The state shape is `%{cart: list, timer_pid: reference | nil}`; extend it to fit your needs.
