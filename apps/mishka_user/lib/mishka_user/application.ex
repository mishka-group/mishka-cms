defmodule MishkaUser.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    token_runner_config = [
      strategy: :one_for_one,
      name: MishkaUser.Token.TokenOtpRunner
    ]

    children = [
      {Registry, keys: :unique, name: MishkaUser.Token.TokenRegistry},
      {DynamicSupervisor, token_runner_config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MishkaUser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
