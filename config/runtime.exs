import Config

config :recent_summoners,
  riot_api_key: System.fetch_env!("RIOT_API_KEY"),
  riot_api_base_domain: System.fetch_env!("RIOT_API_BASE_DOMAIN")

config :hammer,
  backend: {Hammer.Backend.ETS,
            [expiry_ms: 60_000 * 60 * 4,
             cleanup_interval_ms: 60_000 * 10]}
