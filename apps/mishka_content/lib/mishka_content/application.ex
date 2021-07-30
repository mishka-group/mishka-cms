defmodule MishkaContent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    bookmark_runner_config = [
      strategy: :one_for_one,
      name: MishkaContent.Cache.BookmarkOtpRunner
    ]

    children = [
      {Registry, keys: :unique, name: MishkaContent.Cache.BookmarkRegistry},
      {DynamicSupervisor, bookmark_runner_config},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MishkaContent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
