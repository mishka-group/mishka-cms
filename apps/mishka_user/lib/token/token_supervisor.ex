defmodule MishkaUser.Token.TokenSupervisor do
  use Supervisor, restart: :temporary

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      {MishkaUser.Token.TokenManagemnt, args}
    ]

    options = [
      strategy: :one_for_one
    ]

    Supervisor.init(children, options)
  end
end
