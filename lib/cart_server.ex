defmodule CartServer do
  use GenServer

  @moduledoc """
  Documentation for `CartServer`.
  """

  @default_server_name  :default_cart_server
  # Client
  def start_link(opts) do
    name = Keyword.get(opts, :name,  @default_server_name)
    # GenServer.start_link(__MODULE__, %{}, name: :cart_server)
     GenServer.start_link(__MODULE__, %{name: name}, name: name)
  end

  def cart_total(server \\  @default_server_name ), do: GenServer.call(server, :total)

  def add_item(%{name: _name, price: _price, qty: _qty} = item, server \\  @default_server_name), do: GenServer.cast(server, {:add_item, item})

  def remove_item(item, server \\  @default_server_name), do: GenServer.cast(server, {:remove_item, item})

  def find_item(name,  server \\  @default_server_name ) do
    GenServer.call(server, {:find_item, name})
  end

  @impl true
  def init(state) do
    IO.puts("Cart Server is starting #{state.name}")
    {:ok, %{cart: [], timer_ref: nil}}
  end
  # Callbacks
  @impl true
  def handle_call(:total, _from, state) do
    total =
      state.cart
      |> Enum.reduce(0, fn item, acc -> acc + item[:price] * item[:qty] end)

    {:reply, total, state}
  end

  @impl true
  def handle_call({:find_item, name}, _from, state) do
    item = Enum.find(state.cart, fn item -> item.name == name end)
    {:reply, item, state}
  end

  @impl true
  def handle_cast({:add_item, item}, state) do
    new_state = %{state | cart: [item | state.cart]} |> send_reminder()
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove_item, name}, state) do
    new_state = %{state | cart: state.cart |> Enum.filter(fn item -> item.name != name end)} |> send_reminder()
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:send_reminder, state) do
    IO.puts("Don't forget to check out your cart!")
    {:noreply, state}
  end


  defp send_reminder(state) do
    case state.timer_ref do
      nil -> nil
      timer -> Process.cancel_timer(timer)
    end

    case state.cart do
      [] ->
        %{state | timer_ref: nil}
      _items ->
        ref = Process.send_after(self(), :send_reminder, 5_000)
        %{state | timer_ref: ref}

      end
  end

end
