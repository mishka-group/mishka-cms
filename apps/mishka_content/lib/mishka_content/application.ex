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

    content_draft_runner_config = [
      strategy: :one_for_one,
      name: MishkaContent.Cache.ContentDraftOtpRunner
    ]

    children = [
      {Task.Supervisor, name: MishkaContent.Email.EmailHelperTaskSupervisor},
      {Task.Supervisor, name: MishkaContent.General.Notif},
      {Task.Supervisor, name: MishkaContent.General.ActivityTaskSupervisor},
      {Registry, keys: :unique, name: MishkaContent.Cache.BookmarkRegistry},
      {Registry, keys: :unique, name: MishkaContent.Cache.ContentDraftRegistry},
      {DynamicSupervisor, bookmark_runner_config},
      {DynamicSupervisor, content_draft_runner_config},
      %{id: MishkaContent.CorePlugin.Login.SuccessLogin, start: {MishkaContent.CorePlugin.Login.SuccessLogin, :start_link, [[]]}},
      %{id: MishkaContent.CorePlugin.Login.SuccessLogout, start: {MishkaContent.CorePlugin.Login.SuccessLogout, :start_link, [[]]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MishkaContent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
