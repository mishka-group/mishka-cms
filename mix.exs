defmodule MishkaCms.Umbrella.MixProject do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      apps_path: "apps",
      version: @version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "MishkaCms",
      source_url: "https://github.com/mishka-group/mishka-cms",
      homepage_url: "https://mishka.group/",
      description: description(),
      package: package(),
      dialyzer: [
        list_unused_filters: true
      ],
      docs: [
        main: "MishkaCms", # The main page in the docs
        # logo: "path/to/logo.png",
        # extras: ["README.md"]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      setup: ["cmd mix setup"],
      "ecto.setup": ["ecto.drop", "ecto.create", "ecto.migrate"],
    ]
  end

  defp description() do
    "MishkaCms an open source and real time API base CMS Powered by Elixir and Phoenix"
  end

  defp package() do
    [
      files: ~w(apps config .formatter.exs mix.exs LICENSE README*),
      licenses: ["Apache License 2.0"],
      maintainers: ["Shahryar Tavakkoli", "Mojtaba Naseri"],
      links: %{"GitHub" => "https://github.com/mishka-group/mishka-cms"}
    ]
  end
end
