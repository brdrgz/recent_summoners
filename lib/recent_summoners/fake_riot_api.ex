defmodule RecentSummoners.FakeRiotApi do
  use Plug.Router
  use Agent

  plug :match
  plug :dispatch

  def init(options) do
    Agent.start_link(fn -> %{all_matches: all_matches(), puuid_matches: puuid_matches()} end, name: __MODULE__)
    options
  end

  def reset_matches() do
    Agent.update(__MODULE__, fn _ -> %{all_matches: all_matches(), puuid_matches: puuid_matches()} end)
  end

  def get_matches() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def add_match(%{id: match_id, start_time: start_time, participant_puuids: participants}) do
    Agent.update(__MODULE__, fn state ->
      all_matches =
        state
        |> Map.get(:all_matches)
        |> Map.put(match_id, %{
          "metadata" => %{
            "participants" => participants
          },
          "info" => %{ "gameCreation" => start_time }
        })

      puuid_matches =
        participants
        |> Enum.reduce(Map.get(state, :puuid_matches), fn puuid, acc ->
          Map.update(acc, puuid, [], & [match_id | &1])
        end)

      %{all_matches: all_matches, puuid_matches: puuid_matches}
    end)
  end

  get "/lol/summoner/v4/summoners/by-name/:name" do
    response =
      summoner_names()
      |> Map.get(name)

    send_resp(conn, 200, Jason.encode!(response))
  end

  get "/lol/summoner/v4/summoners/by-puuid/:puuid" do
    response =
      summoner_puuids()
      |> Map.get(puuid)

    send_resp(conn, 200, Jason.encode!(response))
  end

  get "/lol/match/v5/matches/by-puuid/:puuid/ids" do
    conn = fetch_query_params(conn)
    count = Map.get(conn.params, "count", 20) |> String.to_integer()
    start_time = Map.get(conn.params, "startTime", nil)

    last_n_matches =
      Agent.get(__MODULE__, & &1)
      |> Map.get(:puuid_matches)
      |> Map.get(puuid, [])
      |> Enum.take(count)

    response =
      case start_time do
        nil -> last_n_matches
        _ -> starting_after(last_n_matches, String.to_integer(start_time))
      end

    send_resp(conn, 200, Jason.encode!(response))
  end

  get "/lol/match/v5/matches/:match_id" do
    response =
      Agent.get(__MODULE__, & &1)
      |> Map.get(:all_matches)
      |> Map.get(match_id)

    send_resp(conn, 200, Jason.encode!(response))
  end

  defp starting_after(matches, start_time) do
    all_matches = Agent.get(__MODULE__, & &1) |> Map.get(:all_matches)
    Enum.filter(matches, fn match_id ->
      match = Map.get(all_matches, match_id)
      match_info = Map.get(match, "info")
      game_creation = Map.get(match_info, "gameCreation")
      match_start_time_in_unix_seconds = trunc(game_creation / 1000)
      match_start_time_in_unix_seconds >= start_time
    end)
  end

  defp summoner_names() do
    %{
      "summonerA" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "cc0bef0ea3ef368a9c99e35d273abff3a86b7f3811840ddbde90a2fcc6047935",
          "name" => "summonerA",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerB" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "5f70ae29b3019ec851ef6b664b59d3fd88dda0de5eb58212ddbd97c65c3f8198",
          "name" => "summonerB",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerC" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "2da7a583d98e76d9d874f8b258534ba049d6f032743d8d0d67b1e8921011718e",
          "name" => "summonerC",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerD" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "846a5c745f84e7788f8d227956d18d1524fbe21975be04c1d20b3fa484cd077c",
          "name" => "summonerD",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerE" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "d17ade7e6c3f41035af90542ffeefba26bb8ace686b0eb3d5d428e42ce7fa2f4",
          "name" => "summonerE",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerF" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "9f4c6b6536ec60834c95e1a8940fd869c83888cdf8a9b55f8e83daba1f4b8793",
          "name" => "summonerF",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerG" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "c607ee0753fd1acc36db150debd534d33ef200b5b62a5899e2ba6778f95ea381",
          "name" => "summonerG",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerH" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "9a3218b3ea424f8141203ebccc91b47acef3de163e950a6650f9a4929763f9e0",
          "name" => "summonerH",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerI" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "afff07cb8b4a9f5203f3df4f4870d21538926b5e5d2360f82c94e8615d076061",
          "name" => "summonerI",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerJ" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "ba46c6d68fd1fec687292cc7395774d38baf07b79840cc2bcf687c3ff9dd0e36",
          "name" => "summonerJ",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerK" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "a001b0b1ff5cc5214c95f16967afe417921e9703deff18ac7fe9f264f61e3775",
          "name" => "summonerK",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerL" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "bc417bc26a50994e3412cfc038c6c9f4410e24ad84d9105603d44387237a5f5a",
          "name" => "summonerL",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerM" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "f49b353b49da5b5b9555fdf042d21fe95309b5f8c759959dd1b32b7d96e20a9c",
          "name" => "summonerM",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerN" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "a74b14f0abbffd5471253bc0c9bd4bded33d68bf21e326e5b12df1e31105ecfd",
          "name" => "summonerN",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerO" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "baefb9e26239e3055062bc78411e607f83f3e5a9239913c77cd322998e04c392",
          "name" => "summonerO",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerP" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
          "name" => "summonerP",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerQ" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "80f61e8d05cee82be121ef2bfdcb3427223aea76af3eda58e0bacb05b083a3f1",
          "name" => "summonerQ",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerR" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "0a5b8afb7df1dea1dd09a6617969f7e01aaaa67a5af6a719d8dcba2c84e7fc27",
          "name" => "summonerR",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerS" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "58d8789e69d18d88a2a10ef9a595bd0645901c92ed3a7e4abe8aa378b919d88b",
          "name" => "summonerS",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerT" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "34983091f00bd3336db97e0dce005a3de7c166c238c8a2a4ec559d6960b71cf0",
          "name" => "summonerT",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerU" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "dbf475222e0b9b18997406165cbc5b5a126e97f5ac292db33fed14d16f7dfb09",
          "name" => "summonerU",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerV" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "8d55396ff0744e6468b8f85bc765fcb85918e1178fbf1568d28fe3692d5f132f",
          "name" => "summonerV",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerW" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "f36653960aa1dbf7ba89b681b4e497b45e80e00553e194c74ee1943ef6e8de5f",
          "name" => "summonerW",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerX" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "90f321d01e2684af3bfbb43340a7fcd4fe7ee21490eee322b9c583fc3ddc32d0",
          "name" => "summonerX",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerY" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "ffbbee75e67c69a745b59a585c8e0872592de07cf330ff5fe34c592950f7cf05",
          "name" => "summonerY",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summonerZ" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "748ebee6a5fdf0abed62456832562162c6e4d958ce44062315a05d0a6133b2b0",
          "name" => "summonerZ",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner1" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "cd026d66c4c861a2a2772bcfd420ffc032c2a2ea12b9dbb9dc342953fe62c291",
          "name" => "summoner1",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner2" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "0a8065fd0dcfe8aa533a4e8032b66f64cf9f31b86b1adf8d10668b9b83fd0fbd",
          "name" => "summoner2",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner3" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "48a905928d048941def91c39593d27861f6bc333a9e8dc3d0ba73771460d6a2a",
          "name" => "summoner3",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner4" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "6db35a46e2ed4e463ef4c3bca8b8d2bfff08d432f74691cb18fd850fdb94c4c3",
          "name" => "summoner4",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner5" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "98b6a2f3825ba49815ddbff0d5c539e08bffdb26c98a9840aca6cb8e6363396d",
          "name" => "summoner5",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner6" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "cb5e59f3ab45e3f4094f320a44bff6cba1acf9baf75beb17196731367b6a6a87",
          "name" => "summoner6",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner7" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "3e246bb8602393b5c2920da5f110e6d1b4f08a26c60c0dd17bce57cc835fe2be",
          "name" => "summoner7",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner8" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "528ffd70b7629743e96a7d280f2e0f3735940db15a18aab1ab0c419929eabf6f",
          "name" => "summoner8",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner9" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "3ffecdcba02929069a072cedb677107cc045345a46d1852ab79eb3beee91bb22",
          "name" => "summoner9",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner0" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "af23c23089857d70396f594148a6b051b2c42ac3b339b3ca404ffb7503dce61c",
          "name" => "summoner0",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner!" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "773b2492cf46ba38a719fd7f6724ad8fd7d1b1ae8cec617e65c38a9363335896",
          "name" => "summoner!",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner@" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "f826d57d70f7bed24279815c2aba5429acd656ff154a5c4edf998455155dd859",
          "name" => "summoner@",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner#" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "fbe89b3f3e9f5bf0e186bc6d42ea48c34be237f8b3d331cc891f65be819ae17e",
          "name" => "summoner#",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner$" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "697831a2b54282c5168a0dfa898c6afe548973a7d8cf269bc45cc6ce90a41c97",
          "name" => "summoner$",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
      "summoner%" =>
        %{
          "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
          "puuid" => "48b2080abede93d96d13d676bfadb2feec26b74eaf09b03329c4e3e00212f02c",
          "name" => "summoner%",
          "profileIconId" => 29,
          "revisionDate" => 1687317487000,
          "summonerLevel" => 67
        },
    }
  end

  defp summoner_puuids() do
    %{
      "98b6a2f3825ba49815ddbff0d5c539e08bffdb26c98a9840aca6cb8e6363396d" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner5",
        "profileIconId" => 29,
        "puuid" => "98b6a2f3825ba49815ddbff0d5c539e08bffdb26c98a9840aca6cb8e6363396d",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "34983091f00bd3336db97e0dce005a3de7c166c238c8a2a4ec559d6960b71cf0" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerT",
        "profileIconId" => 29,
        "puuid" => "34983091f00bd3336db97e0dce005a3de7c166c238c8a2a4ec559d6960b71cf0",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "f826d57d70f7bed24279815c2aba5429acd656ff154a5c4edf998455155dd859" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner@",
        "profileIconId" => 29,
        "puuid" => "f826d57d70f7bed24279815c2aba5429acd656ff154a5c4edf998455155dd859",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "9f4c6b6536ec60834c95e1a8940fd869c83888cdf8a9b55f8e83daba1f4b8793" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerF",
        "profileIconId" => 29,
        "puuid" => "9f4c6b6536ec60834c95e1a8940fd869c83888cdf8a9b55f8e83daba1f4b8793",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "773b2492cf46ba38a719fd7f6724ad8fd7d1b1ae8cec617e65c38a9363335896" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner!",
        "profileIconId" => 29,
        "puuid" => "773b2492cf46ba38a719fd7f6724ad8fd7d1b1ae8cec617e65c38a9363335896",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "f36653960aa1dbf7ba89b681b4e497b45e80e00553e194c74ee1943ef6e8de5f" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerW",
        "profileIconId" => 29,
        "puuid" => "f36653960aa1dbf7ba89b681b4e497b45e80e00553e194c74ee1943ef6e8de5f",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "528ffd70b7629743e96a7d280f2e0f3735940db15a18aab1ab0c419929eabf6f" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner8",
        "profileIconId" => 29,
        "puuid" => "528ffd70b7629743e96a7d280f2e0f3735940db15a18aab1ab0c419929eabf6f",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "0a5b8afb7df1dea1dd09a6617969f7e01aaaa67a5af6a719d8dcba2c84e7fc27" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerR",
        "profileIconId" => 29,
        "puuid" => "0a5b8afb7df1dea1dd09a6617969f7e01aaaa67a5af6a719d8dcba2c84e7fc27",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "6db35a46e2ed4e463ef4c3bca8b8d2bfff08d432f74691cb18fd850fdb94c4c3" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner4",
        "profileIconId" => 29,
        "puuid" => "6db35a46e2ed4e463ef4c3bca8b8d2bfff08d432f74691cb18fd850fdb94c4c3",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "80f61e8d05cee82be121ef2bfdcb3427223aea76af3eda58e0bacb05b083a3f1" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerQ",
        "profileIconId" => 29,
        "puuid" => "80f61e8d05cee82be121ef2bfdcb3427223aea76af3eda58e0bacb05b083a3f1",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "748ebee6a5fdf0abed62456832562162c6e4d958ce44062315a05d0a6133b2b0" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerZ",
        "profileIconId" => 29,
        "puuid" => "748ebee6a5fdf0abed62456832562162c6e4d958ce44062315a05d0a6133b2b0",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "48a905928d048941def91c39593d27861f6bc333a9e8dc3d0ba73771460d6a2a" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner3",
        "profileIconId" => 29,
        "puuid" => "48a905928d048941def91c39593d27861f6bc333a9e8dc3d0ba73771460d6a2a",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "c607ee0753fd1acc36db150debd534d33ef200b5b62a5899e2ba6778f95ea381" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerG",
        "profileIconId" => 29,
        "puuid" => "c607ee0753fd1acc36db150debd534d33ef200b5b62a5899e2ba6778f95ea381",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "8d55396ff0744e6468b8f85bc765fcb85918e1178fbf1568d28fe3692d5f132f" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerV",
        "profileIconId" => 29,
        "puuid" => "8d55396ff0744e6468b8f85bc765fcb85918e1178fbf1568d28fe3692d5f132f",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "afff07cb8b4a9f5203f3df4f4870d21538926b5e5d2360f82c94e8615d076061" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerI",
        "profileIconId" => 29,
        "puuid" => "afff07cb8b4a9f5203f3df4f4870d21538926b5e5d2360f82c94e8615d076061",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "48b2080abede93d96d13d676bfadb2feec26b74eaf09b03329c4e3e00212f02c" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner%",
        "profileIconId" => 29,
        "puuid" => "48b2080abede93d96d13d676bfadb2feec26b74eaf09b03329c4e3e00212f02c",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "ffbbee75e67c69a745b59a585c8e0872592de07cf330ff5fe34c592950f7cf05" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerY",
        "profileIconId" => 29,
        "puuid" => "ffbbee75e67c69a745b59a585c8e0872592de07cf330ff5fe34c592950f7cf05",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "fbe89b3f3e9f5bf0e186bc6d42ea48c34be237f8b3d331cc891f65be819ae17e" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner#",
        "profileIconId" => 29,
        "puuid" => "fbe89b3f3e9f5bf0e186bc6d42ea48c34be237f8b3d331cc891f65be819ae17e",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "5f70ae29b3019ec851ef6b664b59d3fd88dda0de5eb58212ddbd97c65c3f8198" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerB",
        "profileIconId" => 29,
        "puuid" => "5f70ae29b3019ec851ef6b664b59d3fd88dda0de5eb58212ddbd97c65c3f8198",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "cd026d66c4c861a2a2772bcfd420ffc032c2a2ea12b9dbb9dc342953fe62c291" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner1",
        "profileIconId" => 29,
        "puuid" => "cd026d66c4c861a2a2772bcfd420ffc032c2a2ea12b9dbb9dc342953fe62c291",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "cb5e59f3ab45e3f4094f320a44bff6cba1acf9baf75beb17196731367b6a6a87" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner6",
        "profileIconId" => 29,
        "puuid" => "cb5e59f3ab45e3f4094f320a44bff6cba1acf9baf75beb17196731367b6a6a87",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "3e246bb8602393b5c2920da5f110e6d1b4f08a26c60c0dd17bce57cc835fe2be" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner7",
        "profileIconId" => 29,
        "puuid" => "3e246bb8602393b5c2920da5f110e6d1b4f08a26c60c0dd17bce57cc835fe2be",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "af23c23089857d70396f594148a6b051b2c42ac3b339b3ca404ffb7503dce61c" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner0",
        "profileIconId" => 29,
        "puuid" => "af23c23089857d70396f594148a6b051b2c42ac3b339b3ca404ffb7503dce61c",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "9a3218b3ea424f8141203ebccc91b47acef3de163e950a6650f9a4929763f9e0" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerH",
        "profileIconId" => 29,
        "puuid" => "9a3218b3ea424f8141203ebccc91b47acef3de163e950a6650f9a4929763f9e0",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "0a8065fd0dcfe8aa533a4e8032b66f64cf9f31b86b1adf8d10668b9b83fd0fbd" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner2",
        "profileIconId" => 29,
        "puuid" => "0a8065fd0dcfe8aa533a4e8032b66f64cf9f31b86b1adf8d10668b9b83fd0fbd",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "bc417bc26a50994e3412cfc038c6c9f4410e24ad84d9105603d44387237a5f5a" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerL",
        "profileIconId" => 29,
        "puuid" => "bc417bc26a50994e3412cfc038c6c9f4410e24ad84d9105603d44387237a5f5a",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerP",
        "profileIconId" => 29,
        "puuid" => "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "d17ade7e6c3f41035af90542ffeefba26bb8ace686b0eb3d5d428e42ce7fa2f4" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerE",
        "profileIconId" => 29,
        "puuid" => "d17ade7e6c3f41035af90542ffeefba26bb8ace686b0eb3d5d428e42ce7fa2f4",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "58d8789e69d18d88a2a10ef9a595bd0645901c92ed3a7e4abe8aa378b919d88b" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerS",
        "profileIconId" => 29,
        "puuid" => "58d8789e69d18d88a2a10ef9a595bd0645901c92ed3a7e4abe8aa378b919d88b",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "697831a2b54282c5168a0dfa898c6afe548973a7d8cf269bc45cc6ce90a41c97" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner$",
        "profileIconId" => 29,
        "puuid" => "697831a2b54282c5168a0dfa898c6afe548973a7d8cf269bc45cc6ce90a41c97",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "3ffecdcba02929069a072cedb677107cc045345a46d1852ab79eb3beee91bb22" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summoner9",
        "profileIconId" => 29,
        "puuid" => "3ffecdcba02929069a072cedb677107cc045345a46d1852ab79eb3beee91bb22",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "90f321d01e2684af3bfbb43340a7fcd4fe7ee21490eee322b9c583fc3ddc32d0" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerX",
        "profileIconId" => 29,
        "puuid" => "90f321d01e2684af3bfbb43340a7fcd4fe7ee21490eee322b9c583fc3ddc32d0",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "a001b0b1ff5cc5214c95f16967afe417921e9703deff18ac7fe9f264f61e3775" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerK",
        "profileIconId" => 29,
        "puuid" => "a001b0b1ff5cc5214c95f16967afe417921e9703deff18ac7fe9f264f61e3775",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "f49b353b49da5b5b9555fdf042d21fe95309b5f8c759959dd1b32b7d96e20a9c" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerM",
        "profileIconId" => 29,
        "puuid" => "f49b353b49da5b5b9555fdf042d21fe95309b5f8c759959dd1b32b7d96e20a9c",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "a74b14f0abbffd5471253bc0c9bd4bded33d68bf21e326e5b12df1e31105ecfd" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerN",
        "profileIconId" => 29,
        "puuid" => "a74b14f0abbffd5471253bc0c9bd4bded33d68bf21e326e5b12df1e31105ecfd",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "baefb9e26239e3055062bc78411e607f83f3e5a9239913c77cd322998e04c392" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerO",
        "profileIconId" => 29,
        "puuid" => "baefb9e26239e3055062bc78411e607f83f3e5a9239913c77cd322998e04c392",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "846a5c745f84e7788f8d227956d18d1524fbe21975be04c1d20b3fa484cd077c" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerD",
        "profileIconId" => 29,
        "puuid" => "846a5c745f84e7788f8d227956d18d1524fbe21975be04c1d20b3fa484cd077c",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "2da7a583d98e76d9d874f8b258534ba049d6f032743d8d0d67b1e8921011718e" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerC",
        "profileIconId" => 29,
        "puuid" => "2da7a583d98e76d9d874f8b258534ba049d6f032743d8d0d67b1e8921011718e",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "cc0bef0ea3ef368a9c99e35d273abff3a86b7f3811840ddbde90a2fcc6047935" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerA",
        "profileIconId" => 29,
        "puuid" => "cc0bef0ea3ef368a9c99e35d273abff3a86b7f3811840ddbde90a2fcc6047935",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "dbf475222e0b9b18997406165cbc5b5a126e97f5ac292db33fed14d16f7dfb09" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerU",
        "profileIconId" => 29,
        "puuid" => "dbf475222e0b9b18997406165cbc5b5a126e97f5ac292db33fed14d16f7dfb09",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      },
      "ba46c6d68fd1fec687292cc7395774d38baf07b79840cc2bcf687c3ff9dd0e36" => %{
        "accountId" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "id" => "d1bc8d3ba4afc7e109612cb73acbdddac052c93025aa1f82942edabb7deb82a1",
        "name" => "summonerJ",
        "profileIconId" => 29,
        "puuid" => "ba46c6d68fd1fec687292cc7395774d38baf07b79840cc2bcf687c3ff9dd0e36",
        "revisionDate" => 1687317487000,
        "summonerLevel" => 67
      }
    }
  end

  defp puuid_matches() do
    %{
      "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642" =>
        [
          "TESTREGION_4689896112",
          "TESTREGION_4684686779",
          "TESTREGION_4684655043",
          "TESTREGION_4684255303",
          "TESTREGION_4683835124",
          "TESTREGION_4683801830",
          "TESTREGION_4683310580",
          "TESTREGION_4682889706",
          "TESTREGION_4682870262",
          "TESTREGION_4682832917",
          "TESTREGION_4682627383",
          "TESTREGION_4682363769",
          "TESTREGION_4682141664",
          "TESTREGION_4682117730",
          "TESTREGION_4682082640",
          "TESTREGION_4682070954",
          "TESTREGION_4681965745",
          "TESTREGION_4681326198",
          "TESTREGION_4681307275",
          "TESTREGION_4681284234"
        ],
      "cc0bef0ea3ef368a9c99e35d273abff3a86b7f3811840ddbde90a2fcc6047935" =>
        [
          "TESTREGION_4701864509",
          "TESTREGION_4701863895",
          "TESTREGION_4701837831",
          "TESTREGION_4700866528",
          "TESTREGION_4700856735",
          "TESTREGION_4700830474",
          "TESTREGION_4700814331",
          "TESTREGION_4698766833",
          "TESTREGION_4697996354",
          "TESTREGION_4697971575",
          "TESTREGION_4697950740",
          "TESTREGION_4697923535",
          "TESTREGION_4697865131",
          "TESTREGION_4697840889",
          "TESTREGION_4696912067",
          "TESTREGION_4696874269",
          "TESTREGION_4696825311",
          "TESTREGION_4696801891",
          "TESTREGION_4696339946",
          "TESTREGION_4695982059"
      ],
      "c607ee0753fd1acc36db150debd534d33ef200b5b62a5899e2ba6778f95ea381" =>
        [
          "TESTREGION_4699262804",
          "TESTREGION_4698703924",
          "TESTREGION_4698657679",
          "TESTREGION_4698276173",
          "TESTREGION_4698238148",
          "TESTREGION_4697320598",
          "TESTREGION_4697303891",
          "TESTREGION_4695834823",
          "TESTREGION_4695767657",
          "TESTREGION_4695703572",
          "TESTREGION_4694452696",
          "TESTREGION_4689935581",
          "TESTREGION_4689896112",
          "TESTREGION_4687883097",
          "TESTREGION_4687825016",
          "TESTREGION_4686463537",
          "TESTREGION_4685326413",
          "TESTREGION_4685302534",
          "TESTREGION_4681193381",
          "TESTREGION_4681157364"
        ],
      "3e246bb8602393b5c2920da5f110e6d1b4f08a26c60c0dd17bce57cc835fe2be" =>
        [
          "TESTREGION_4701661241",
          "TESTREGION_4701635292",
          "TESTREGION_4701433395",
          "TESTREGION_4701388720",
          "TESTREGION_4701352311",
          "TESTREGION_4701312971",
          "TESTREGION_4701230369",
          "TESTREGION_4700660858",
          "TESTREGION_4700389223",
          "TESTREGION_4700357013",
          "TESTREGION_4700331971",
          "TESTREGION_4699721550",
          "TESTREGION_4699689496",
          "TESTREGION_4699300420",
          "TESTREGION_4699290035",
          "TESTREGION_4699249023",
          "TESTREGION_4698703924",
          "TESTREGION_4697333912",
          "TESTREGION_4695849918",
          "TESTREGION_4695561482"
        ]
    }
  end

  defp all_matches() do
    %{
      "TESTREGION_4701864509" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
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
            },
          "info" =>
            %{
              "gameCreation" => 1687316035538
            }
        },
      "TESTREGION_4699262804" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
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
            },
          "info" =>
            %{
              "gameCreation" => 1687316035538
            }
        },
      "TESTREGION_4701661241" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
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
            },
          "info" =>
            %{
              "gameCreation" => 1687316035538
            }
        },
      "TESTREGION_4689896112" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
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
            },
          "info" =>
            %{
              "gameCreation" => 1687316035538
            }
        },
      "TESTREGION_4684686779" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
                  "ba46c6d68fd1fec687292cc7395774d38baf07b79840cc2bcf687c3ff9dd0e36",
                  "a001b0b1ff5cc5214c95f16967afe417921e9703deff18ac7fe9f264f61e3775",
                  "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
                  "bc417bc26a50994e3412cfc038c6c9f4410e24ad84d9105603d44387237a5f5a",
                  "f49b353b49da5b5b9555fdf042d21fe95309b5f8c759959dd1b32b7d96e20a9c",
                  "a74b14f0abbffd5471253bc0c9bd4bded33d68bf21e326e5b12df1e31105ecfd",
                  "baefb9e26239e3055062bc78411e607f83f3e5a9239913c77cd322998e04c392",
                  "80f61e8d05cee82be121ef2bfdcb3427223aea76af3eda58e0bacb05b083a3f1",
                  "0a5b8afb7df1dea1dd09a6617969f7e01aaaa67a5af6a719d8dcba2c84e7fc27",
                  "58d8789e69d18d88a2a10ef9a595bd0645901c92ed3a7e4abe8aa378b919d88b"
                ]
            },
          "info" =>
            %{
              "gameCreation" => 1686883536667
            }
        },
      "TESTREGION_4684655043" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
                  "34983091f00bd3336db97e0dce005a3de7c166c238c8a2a4ec559d6960b71cf0",
                  "dbf475222e0b9b18997406165cbc5b5a126e97f5ac292db33fed14d16f7dfb09",
                  "80f61e8d05cee82be121ef2bfdcb3427223aea76af3eda58e0bacb05b083a3f1",
                  "8d55396ff0744e6468b8f85bc765fcb85918e1178fbf1568d28fe3692d5f132f",
                  "f36653960aa1dbf7ba89b681b4e497b45e80e00553e194c74ee1943ef6e8de5f",
                  "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
                  "baefb9e26239e3055062bc78411e607f83f3e5a9239913c77cd322998e04c392",
                  "90f321d01e2684af3bfbb43340a7fcd4fe7ee21490eee322b9c583fc3ddc32d0",
                  "ffbbee75e67c69a745b59a585c8e0872592de07cf330ff5fe34c592950f7cf05",
                  "bc417bc26a50994e3412cfc038c6c9f4410e24ad84d9105603d44387237a5f5a"
                ]
            },
          "info" =>
            %{
              "gameCreation" => 1686881979950
            }
        },
      "TESTREGION_4684255303" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
                  "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
                  "748ebee6a5fdf0abed62456832562162c6e4d958ce44062315a05d0a6133b2b0",
                  "cd026d66c4c861a2a2772bcfd420ffc032c2a2ea12b9dbb9dc342953fe62c291",
                  "0a8065fd0dcfe8aa533a4e8032b66f64cf9f31b86b1adf8d10668b9b83fd0fbd",
                  "48a905928d048941def91c39593d27861f6bc333a9e8dc3d0ba73771460d6a2a",
                  "6db35a46e2ed4e463ef4c3bca8b8d2bfff08d432f74691cb18fd850fdb94c4c3",
                  "baefb9e26239e3055062bc78411e607f83f3e5a9239913c77cd322998e04c392",
                  "98b6a2f3825ba49815ddbff0d5c539e08bffdb26c98a9840aca6cb8e6363396d",
                  "cb5e59f3ab45e3f4094f320a44bff6cba1acf9baf75beb17196731367b6a6a87",
                  "3e246bb8602393b5c2920da5f110e6d1b4f08a26c60c0dd17bce57cc835fe2be"
                ]
            },
          "info" =>
            %{
              "gameCreation" => 1686855129100
            }
        },
      "TESTREGION_4683835124" =>
        %{
          "metadata" =>
            %{
              "participants" =>
                [
                  "528ffd70b7629743e96a7d280f2e0f3735940db15a18aab1ab0c419929eabf6f",
                  "3ffecdcba02929069a072cedb677107cc045345a46d1852ab79eb3beee91bb22",
                  "af23c23089857d70396f594148a6b051b2c42ac3b339b3ca404ffb7503dce61c",
                  "773b2492cf46ba38a719fd7f6724ad8fd7d1b1ae8cec617e65c38a9363335896",
                  "f826d57d70f7bed24279815c2aba5429acd656ff154a5c4edf998455155dd859",
                  "fbe89b3f3e9f5bf0e186bc6d42ea48c34be237f8b3d331cc891f65be819ae17e",
                  "697831a2b54282c5168a0dfa898c6afe548973a7d8cf269bc45cc6ce90a41c97",
                  "b4ee1e6d17cf87647e3d929ae93d5f7556c94e51d7f2ad5c3e542768baec6642",
                  "846a5c745f84e7788f8d227956d18d1524fbe21975be04c1d20b3fa484cd077c",
                  "48b2080abede93d96d13d676bfadb2feec26b74eaf09b03329c4e3e00212f02c"
                ]
            },
          "info" =>
            %{
              "gameCreation" => 1686807058799
            }
        }
    }
  end
end
