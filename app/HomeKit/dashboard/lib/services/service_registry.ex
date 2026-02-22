defmodule Dashboard.Services.ServiceRegistry do
  use GenServer

  def start_link(_),
    do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def register(service_name, port),
    do: GenServer.cast(__MODULE__, {:register, service_name, port})

  def unregister(service_name),
    do: GenServer.cast(__MODULE__, {:unregister, service_name})

  def get(service_name),
    do: GenServer.call(__MODULE__, {:get, service_name})

  def init(state), do: {:ok, state}

  def handle_cast({:register, name, port}, state) do
    {:noreply, Map.put(state, name, port)}
  end

  def handle_cast({:unregister, name}, state) do
    {:noreply, Map.delete(state, name)}
  end

  def handle_call({:get, name}, _from, state) do
    {:reply, Map.get(state, name), state}
  end
end
