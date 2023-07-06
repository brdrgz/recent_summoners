defmodule MatchMonitor do
  use GenServer
  require Logger

  @stop_after 60_000 * 60
  @fetch_interval 60_000

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    Process.send(self(), :get_new_matches, [])
    schedule_termination()
    {:ok, state}
  end

  @impl true
  def handle_info(:get_new_matches, [puuid, name, region, start_time]) do
    # matches take roughly 20 minutes, so only need to fetch 1 result each minute
    RiotApiClient.matches_by_puuid(puuid, region, 1, start_time)
    |> Enum.map(&("Summoner '#{name}' completed match #{&1}"))
    |> Enum.each(&Logger.info/1)

    schedule_next_fetch()

    {:noreply, [puuid, name, region, System.os_time(:second)]}
  end

  @impl true
  def handle_info(:stop_monitoring, state) do
    {:stop, :shutdown, state}
  end

  defp schedule_next_fetch() do
    Process.send_after(self(), :get_new_matches, @fetch_interval)
  end

  defp schedule_termination() do
    Process.send_after(self(), :stop_monitoring, @stop_after)
  end
end
