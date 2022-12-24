defmodule Aoc2022.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc2022,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Aoc2022.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libgraph, "~> 0.7"},
      {:remix, "~> 0.0.1", only: :dev},
      {:matrix, "~> 0.3.0" },
      {:memoize, "~> 1.4"},
      {:comb, git: "https://github.com/tallakt/comb.git", tag: "master"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
