defmodule RecentSummoners.MixProject do
  use Mix.Project

  def project do
    [
      app: :recent_summoners,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {RecentSummoners.Application, [env: Mix.env()]}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.0"},
      {:hammer, "~> 6.1"}
    ]
  end
end
