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

    acl_runner_config = [
      strategy: :one_for_one,
      name: MishkaUser.Acl.AclOtpRunner
    ]

    children = [
      {Registry, keys: :unique, name: MishkaUser.Token.TokenRegistry},
      {DynamicSupervisor, token_runner_config},

      {Registry, keys: :unique, name: MishkaUser.Acl.AclRegistry},
      {DynamicSupervisor, acl_runner_config},
      {MishkaUser.Acl.AclTask, []},
      {Finch, name: MyHttpClient},
      %{id: MishkaUser.CorePlugin.Login.SuccessLogin, start: {MishkaUser.CorePlugin.Login.SuccessLogin, :start_link, [[]]}},
      %{id: MishkaUser.CorePlugin.Login.SuccessLogout, start: {MishkaUser.CorePlugin.Login.SuccessLogout, :start_link, [[]]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MishkaUser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
