defmodule RecentSummoners.Application do
  use Application

  def start(_type, args) do
    children = case args do
      [env: :test] -> [
        {
          Plug.Cowboy,
          scheme: :https,
          plug: RecentSummoners.FakeRiotApi,
          options: [
            port: 8443,
            cipher_suite: :strong,
            certfile: "priv/cert/selfsigned.pem",
            keyfile: "priv/cert/selfsigned_key.pem",
            otp_app: :recent_summoners
          ]
        }
      ]
      [_] -> []
    end
    Supervisor.start_link(children, [strategy: :one_for_one, name: RecentSummoners.Supervisor])
  end
end
