defmodule MishkaHtml.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_html,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MishkaHtml.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :mishka_user, :mishka_content, :mishka_translator]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6", override: true},
      {:phoenix_live_view, "~> 0.17.7", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:floki, ">= 0.32.0", only: :test},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6.1"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:mishka_user, in_umbrella: true},
      {:mishka_content, in_umbrella: true},
      {:slugify, "~> 1.3"},
      {:html_sanitize_ex, "~> 1.4"},
      {:mishka_translator, in_umbrella: true},
      {:esbuild, "~> 0.3.4", runtime: Mix.env() == :dev},
      {:sobelow, "~> 0.11.1", only: :dev},
      {:jalaali, "~> 0.4.0"},
      {:mishka_installer, "~> 0.0.1"},
      {:mishka_social, "~> 0.0.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
