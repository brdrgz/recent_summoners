defmodule MatchMonitorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  setup_all do
    Hammer.delete_buckets("requests_per_second")
    Hammer.delete_buckets("requests_per_two_minutes")
    on_exit(fn -> RecentSummoners.FakeRiotApi.reset_matches() end)
    :ok
  end

  test "logs new matches for given summoner" do
    puuid = "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642"
    region = "americas"
    name = "summonerP"
    initial_request_time = System.os_time(:second)
    new_match_time = System.os_time()
    :ok = RecentSummoners.FakeRiotApi.add_match(%{
      id: "ABC1_1234",
      start_time: new_match_time,
      participant_puuids: [puuid, "someoneelse", "anotherperson"]
    })
    assert capture_log(fn ->
      GenServer.start_link(MatchMonitor, [puuid, name, region, initial_request_time])
      Process.sleep(100)
    end) =~ "Summoner 'summonerP' completed match"
  end
end
