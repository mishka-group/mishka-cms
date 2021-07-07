defmodule MishkaUser.Acl.AclSupervisor do
  use Supervisor, restart: :transient

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      {MishkaUser.Acl.AclManagement, args}
    ]

    options = [
      strategy: :one_for_one
    ]

    Supervisor.init(children, options)
  end
end
