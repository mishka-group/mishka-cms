defmodule MishkaCms.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "MishkaCms",
      source_url: "https://github.com/mishka-group/mishka-cms",
      homepage_url: "https://trangell.com/",
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
      setup: ["cmd mix setup"],
      "ecto.setup": ["ecto.drop", "ecto.create", "ecto.migrate"],
    ]
  end
end
