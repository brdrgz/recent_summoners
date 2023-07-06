defmodule RecentSummonersTest do
  use ExUnit.Case
  doctest RecentSummoners

  setup do
    :inets.start()
    :ssl.start()
    Hammer.delete_buckets("requests_per_second")
    Hammer.delete_buckets("requests_per_two_minutes")
    :ok
  end

  test "find returns all summoners from last 5 matches" do
    recent_summoners = RecentSummoners.find("summonerP", "na1")
    assert recent_summoners == [
      "summonerA",
      "summonerB",
      "summonerC",
      "summonerD",
      "summonerE",
      "summonerF",
      "summonerG",
      "summonerH",
      "summonerI",
      "summonerJ",
      "summonerK",
      "summonerL",
      "summonerM",
      "summonerN",
      "summonerO",
      "summonerQ",
      "summonerR",
      "summonerS",
      "summonerT",
      "summonerU",
      "summonerV",
      "summonerW",
      "summonerX",
      "summonerY",
      "summonerZ",
      "summoner1",
      "summoner2",
      "summoner3",
      "summoner4",
      "summoner5",
      "summoner6",
      "summoner7",
      "summoner8",
      "summoner9",
      "summoner0",
      "summoner!",
      "summoner@",
      "summoner#",
      "summoner$",
      "summoner%"
    ]
  end
end
