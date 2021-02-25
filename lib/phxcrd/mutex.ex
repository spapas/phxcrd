defmodule Phxcrd.Mutex do
  use GenServer
  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, {MapSet.new(), Map.new()}, name: __MODULE__)

  def lock(id) do
    resp = GenServer.call(__MODULE__, {:lock, id})
    Logger.info("Got reply from API LOCK #{resp|>inspect}")
    case resp do
      :ok -> :ok
      _ -> :error
    end
  end

  @impl true
  def init(locks) do
    Logger.info("Mutex start")
    {:ok, locks}
  end

  @impl true
  def handle_call({:lock, id}, {pid, _term}, {set, map}=locks) do
    Logger.info("Call handler #{id}, #{pid|>inspect}")
    if MapSet.member?(set, id) do
      Logger.info("IS MEMBER SHOULD LOCK")
      {:reply, :error, locks}
    else
      Logger.info("IS NOT MEMBER SHOULD MONITOR")
      Process.monitor(pid)
      {:reply, :ok,  {
        MapSet.put(set, id),
        Map.put(map, pid, id)
      }}
    end
  end

  @impl true
  def handle_cast(_req, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, {set, map}) do
    Logger.info("DOWN handler for #{pid|>inspect}")
    if Map.has_key?(map, pid) do

      {val, new_map} = Map.pop!(map, pid)
      {:noreply, {
        MapSet.delete(set, val),
        new_map
        }}
      else
        {:noreply, {set, map}}
      end
  end
end
