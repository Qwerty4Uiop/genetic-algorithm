defmodule Ga.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ga,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"}
    ]
  end
end
