start_shell:
	cd deployment/docker; chmod +x mishka.sh; sudo ./mishka.sh;

start_elixir:
	mix deps.get
	mix deps.compile
	mix ecto.create
	cd apps/mishka_database; mix mishka_installer.db.gen.migration || true
	mix ecto.migrate
	mix assets.deploy  || true
	mix run apps/mishka_database/priv/repo/seeds.exs
	iex -S mix phx.server
