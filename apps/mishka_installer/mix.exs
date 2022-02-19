defmodule MishkaInstaller.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_installer,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mishka_database, :mishka_content],
      mod: {MishkaInstaller.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mishka_database, in_umbrella: true},
      {:mishka_content, in_umbrella: true},
      {:mishka_developer_tools, "~> 0.0.5"}
    ]
  end
end
