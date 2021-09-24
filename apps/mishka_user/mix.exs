defmodule MishkaUser.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_user,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      compilers: [:gettext | Mix.compilers()],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mishka_database, :phoenix, :mnesia, :mishka_content, :mishka_translator, :jose],
      mod: {MishkaUser.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mishka_database, in_umbrella: true},
      {:mishka_content, in_umbrella: true},
      {:mishka_translator, in_umbrella: true},
      {:plug, "~> 1.12"},
      {:guardian, "~> 2.2"},
      {:phoenix, "~> 1.6", override: true},
      {:jose, "~> 1.11"},
      {:finch, "~> 0.8.1"}
    ]
  end
end
