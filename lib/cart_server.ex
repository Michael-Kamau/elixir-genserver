defmodule CartServer do
  use GenServer

  @moduledoc """
  Documentation for `CartServer`.
  """
  # Client
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: :cart_server)
  end

  def cart_total, do: GenServer.call(:cart_server, :total)

  def add_item(item), do: GenServer.cast(:cart_server, {:add_item, item})

  def find_item(name) do
    GenServer.call(:cart_server, {:find_item, name})
  end

  @impl true
  def init(_state) do
    {:ok, %{cart: [], timer_pid: nil}}
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
  def handle_info(:send_reminder, state) do
    IO.puts("Don't forget to check out your cart!")
    {:noreply, state}
  end


  defp send_reminder(state) do

    case state.timer_pid do
      nil -> nil
      timer -> Process.cancel_timer(timer)
    end

    pid = Process.send_after(self(), :send_reminder, 5_000)
    %{state | timer_pid: pid}
  end

end
