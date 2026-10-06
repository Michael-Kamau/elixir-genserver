defmodule CartDynamicSupervisor do

  use DynamicSupervisor

  def start_link(_opt) do
    DynamicSupervisor.start_link(
      __MODULE__,
      :ok,
      name: __MODULE__
    )
  end


  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)

  end

  def start_cart(name) do
    child_spec = {CartServer, [name: name]}

    DynamicSupervisor.start_child(
      __MODULE__, child_spec
    )
  end

end
