defmodule MishkaUser.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: MishkaUser.Token.UserToken},
      MishkaUser.Token.TokenManagemnt,
      {Registry, keys: :unique, name: MishkaUser.Acl.AclRegistry},
      {DynamicSupervisor, [strategy: :one_for_one, name: MishkaUser.Acl.AclOtpRunner]},
      {MishkaUser.Acl.AclTask, []},
      {Finch, name: MyHttpClient},
      %{
        id: MishkaUser.CorePlugin.Login.SuccessLogin,
        start: {MishkaUser.CorePlugin.Login.SuccessLogin, :start_link, [[]]}
      },
      %{
        id: MishkaUser.CorePlugin.Login.SuccessLogout,
        start: {MishkaUser.CorePlugin.Login.SuccessLogout, :start_link, [[]]}
      }
    ]

    opts = [strategy: :one_for_one, name: MishkaUser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
