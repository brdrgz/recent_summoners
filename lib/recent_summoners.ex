defmodule RecentSummoners do
  def find(summoner_name, platform) do
    %{"puuid" => puuid} = RiotApiClient.summoner_by_name(summoner_name, platform)
    region = region_for_platform(platform)
    summoner_puuids = summoners_played_with(puuid, region)
    current_unix_time = System.os_time(:second)

    summoner_puuids_and_names =
      summoner_puuids
      |> Enum.map(fn puuid ->
        %{"name" => name} = RiotApiClient.summoner_by_puuid(puuid, platform)
        {puuid, name}
      end)

    Enum.map(summoner_puuids_and_names, fn {puuid, name} ->
      MatchMonitor.start_link([puuid, name, region, current_unix_time])
    end)

    Enum.map(summoner_puuids_and_names, &(elem(&1, 1)))
  end

  defp summoners_played_with(puuid, region) do
    RiotApiClient.matches_by_puuid(puuid, region)
      |> Enum.flat_map(fn match_id ->
        %{
          "metadata" =>
            %{
              "participants" => participants
            }
        } = RiotApiClient.match(match_id, region)
        participants
      end)
      |> Enum.reject(&(&1 == puuid))
      |> Enum.uniq()
  end

  defp region_for_platform(platform) do
    Map.fetch!(platforms_to_regions(), platform)
  end

  defp platforms_to_regions() do
    %{
      "br1"  => "americas",
      "eun1" => "europe",
      "euw1" => "europe",
      "jp1"  => "asia",
      "kr"   => "asia",
      "la1"  => "americas",
      "la2"  => "americas",
      "na1"  => "americas",
      "oc1"  => "asia",
      "tr1"  => "europe",
      "ru"   => "europe",
      "ph2"  => "sea",
      "sg2"  => "sea",
      "th2"  => "sea",
      "tw2"  => "sea",
      "vn2"  => "sea",
    }
  end
end
