defmodule ReleaseTime.HttpCache do
  use GenServer
  require Logger

  ##############################################################################
  # Client API
  ##############################################################################

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  ##############################################################################
  # Server API
  ##############################################################################

  def init(:ok) do
    cache = %{}
    {:ok, cache}
  end

  def handle_cast({:set, key, value}, cache) do
    cache = cache |> Map.put(key, value)
    schedule_expire(key)
    log "Caching key #{key}"
    {:noreply, cache}
  end

  def handle_call({:get, key}, _from, cache) do
    value = cache |> Map.get(key)

    case value do
      nil -> (
        {:reply, :miss, cache}
      )
      _ -> (
        log "Cache hit for key #{key}"
        {:reply, {:hit, value}, cache}  
      )
    end
  end

  def handle_info({:expire_key, key}, cache) do
    log "Expiring cache key #{key}"
    cache = cache |> Map.delete(key)
    {:noreply, cache}
  end

  ##############################################################################
  # Private
  ##############################################################################

  defp schedule_expire(key) do
    # Expire cache after two minutes
    Process.send_after(self(), {:expire_key, key}, 2 * 1000 * 60)
  end

  defp log(message) do
    prefix = "[HttpCache] "
    Logger.info prefix <> message
  end
end
