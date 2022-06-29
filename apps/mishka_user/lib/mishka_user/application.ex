defmodule MishkaUser.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @impl true
  def start(_type, _args) do
    # To support elixir 1.14, Ref: https://hexdocs.pm/elixir/main/Task.Supervisor.html#module-scalability-and-partitioning
    user_token_task =
      if Code.ensure_loaded?(PartitionSupervisor) do
        [{PartitionSupervisor, child_spec: Task.Supervisor, name: MishkaUser.Token.UserToken}]
      else
        [{Task.Supervisor, name: MishkaUser.Token.UserToken}]
      end

    children =
      user_token_task ++
        [
          MishkaUser.Token.TokenManagemnt,
          MishkaUser.Acl.AclManagement,
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
