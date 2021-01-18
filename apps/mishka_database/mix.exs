defmodule MishkaDatabase.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_database,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      aliases: aliases(),
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MishkaDatabase.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.5"},
      {:postgrex, "~> 0.15.7"},
      {:comeonin, "~> 5.3"},
      {:bcrypt_elixir, "~> 2.3"},
      {:ecto_enum, "~> 1.4"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
