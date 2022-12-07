defmodule D07.MixProject do
  use Mix.Project

  def project do
    [
      app: :d07,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      applications: applications(Mix.env),
      extra_applications: [:logger],
      mod: {D07.Application, []}
    ]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:logger]

  defp deps do
    [
      {:libgraph, "~> 0.7"},
      {:remix, "~> 0.0.1", only: :dev},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
