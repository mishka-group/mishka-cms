defmodule MishkaInstaller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias MsihkaSendingEmailPlugin.{SendingEmail, SendingSMS, SendingHalt}
  @impl true
  def start(_type, _args) do
    plugin_runner_config = [
      strategy: :one_for_one,
      name: PluginStateOtpRunner
    ]

    test_plugin = if Mix.env in [:test] do
      [
        %{id: SendingEmail, start: {SendingEmail, :start_link, [[]]}},
        %{id: SendingSMS, start: {SendingSMS, :start_link, [[]]}},
        %{id: SendingHalt, start: {SendingHalt, :start_link, [[]]}}
      ]
    else
      []
    end

    children = [
      {Registry, keys: :unique, name: PluginStateRegistry},
      {DynamicSupervisor, plugin_runner_config}
    ] ++ test_plugin

    opts = [strategy: :one_for_one, name: MishkaInstaller.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
