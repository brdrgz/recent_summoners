defmodule RiotApiClientTest do
  use ExUnit.Case

  test "summoner_by_name returns data (SummonerDTO) for given player" do
    name = "summonerP"
    region = "na1"
    response =
      RiotApiClient.summoner_by_name(name, region)
    assert ^response = %{
      "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
      "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
      "puuid" => "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
      "name" => "summonerP",
      "profileIconId" => 29,
      "revisionDate" => 1687317487000,
      "summonerLevel" => 67
    }
  end

  test "summoner_by_puuid returns data (SummonerDTO) for given player" do
    puuid = "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642"
    region = "na1"
    response =
      RiotApiClient.summoner_by_puuid(puuid, region)
    assert ^response = %{
      "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
      "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
      "puuid" => "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
      "name" => "summonerP",
      "profileIconId" => 29,
      "revisionDate" => 1687317487000,
      "summonerLevel" => 67
    }
  end

  test "matches_by_puuid returns list of match ids for given player" do
    puuid = "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642"
    response =
      RiotApiClient.matches_by_puuid(puuid, "americas")
    assert ^response = [
      "TESTREGION_4689896112",
      "TESTREGION_4684686779",
      "TESTREGION_4684655043",
      "TESTREGION_4684255303",
      "TESTREGION_4683835124"
    ]
  end

  test "matches_by_puuid returns list of match ids for given player, limited by count" do
    puuid = "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642"
    response =
      RiotApiClient.matches_by_puuid(puuid, "americas", 1)
    assert ^response = [
      "TESTREGION_4689896112"
    ]
  end

  test "matches_by_puuid returns list of match ids for given player, filtered by start time" do
    puuid = "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642"
    response =
      RiotApiClient.matches_by_puuid(puuid, "americas", 5, 1686881978)
    assert ^response = [
      "TESTREGION_4689896112",
      "TESTREGION_4684686779",
      "TESTREGION_4684655043"
    ]
  end

  test "match returns data (MatchDTO) containing metadata with list of participants (puuids)" do
    match_id = "TESTREGION_4689896112"
    response =
      RiotApiClient.match(match_id, "americas")
    assert ^response = %{
      "info" => %{
        "gameCreation" => 1687316035538
      },
      "metadata" => %{
        "participants" => [
          "cc0bef0ea3ef368a9c99e35d273abff3a86b7f3811840ddbde90a2fcc6047935",
          "5f70ae29b3019ec851ef6b664b59d3fd88dda0de5eb58212ddbd97c65c3f8198",
          "2da7a583d98e76d9d874f8b258534ba049d6f032743d8d0d67b1e8921011718e",
          "846a5c745f84e7788f8d227956d18d1524fbe21975be04c1d20b3fa484cd077c",
          "d17ade7e6c3f41035af90542ffeefba26bb8ace686b0eb3d5d428e42ce7fa2f4",
          "9f4c6b6536ec60834c95e1a8940fd869c83888cdf8a9b55f8e83daba1f4b8793",
          "c607ee0753fd1acc36db150debd534d33ef200b5b62a5899e2ba6778f95ea381",
          "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
          "9a3218b3ea424f8141203ebccc91b47acef3de163e950a6650f9a4929763f9e0",
          "afff07cb8b4a9f5203f3df4f4870d21538926b5e5d2360f82c94e8615d076061"
        ]
      }
    }
  end
end
