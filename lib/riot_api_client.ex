defmodule RiotApiClient do

  # hardcoding these rate limits for simplicity
  @rate_limit_a {1_000, 18}
  @rate_limit_b {120_000, 90}

  def summoner_by_name(name, region) do
    "https://#{region}.#{base_domain()}/lol/summoner/v4/summoners/by-name/#{URI.encode(name)}"
    |> make_rate_limited_request()
  end

  def summoner_by_puuid(puuid, region) do
    "https://#{region}.#{base_domain()}/lol/summoner/v4/summoners/by-puuid/#{URI.encode(puuid)}"
    |> make_rate_limited_request()
  end

  def matches_by_puuid(puuid, region, count \\ 5, start_time \\ nil) do
    url = "https://#{region}.#{base_domain()}/lol/match/v5/matches/by-puuid/#{URI.encode(puuid)}/ids?count=#{count}"
    url =
      case start_time do
        nil -> url
        _ -> url <> "&startTime=#{start_time}"
      end

    make_rate_limited_request(url)
  end

  def match(match_id, region) do
    "https://#{region}.#{base_domain()}/lol/match/v5/matches/#{URI.encode(match_id)}"
    |> make_rate_limited_request()
  end

  defp make_rate_limited_request(url) do
    case {
      Hammer.check_rate("requests_per_second", elem(@rate_limit_a, 0), elem(@rate_limit_a, 1)),
      Hammer.check_rate("requests_per_two_minutes", elem(@rate_limit_b, 0), elem(@rate_limit_b, 1))
      } do
      {{:allow, _rps_count}, {:allow, _rp2m_count}} ->
        {:ok, {_status, _response_headers, body}} = :httpc.request(:get, {url, request_headers()}, ssl_opts(), [])
        Jason.decode!(body)
      _ ->
        Process.sleep(500) # linear backoff
        make_rate_limited_request(url)
    end
  end

  defp base_domain() do
    Application.get_env(:recent_summoners, :riot_api_base_domain)
  end

  defp api_key() do
    Application.get_env(:recent_summoners, :riot_api_key)
  end

  defp request_headers() do
    [{'X-Riot-Token', api_key()}]
  end

  defp ssl_opts() do
    [{:ssl, [{:verify, :verify_none}]}]  # change to :verify_peer
  end
end
