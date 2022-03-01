defmodule MsihkaSendingEmailPlugin.SendingEmail do
  alias MishkaInstaller.{PluginState, Hook}
  use GenServer, restart: :transient
  require Logger
  @ref :on_user_after_login

  @behaviour MishkaInstaller.Reference.OnUserAfterLogin

  def initial(args) do
    Logger.info("SendingEmail plugin was started")
    event = %PluginState{name: "MsihkaSendingEmailPlugin.SendingEmail", event: Atom.to_string(@ref), priority: 100}
    Hook.register(event: event)
    {:ok, @ref, args}
  end

  def call(_user_info, _ip, _endpoint, _status) do
    # {:reply, new_state} | {:noreply, :halt}
  end

  def stop(registerd_info) do
    case Hook.stop(module: registerd_info.name) do
      {:ok, :stop, msg} -> {:ok, @ref, msg}
      {:error, :stop, msg} -> {:error, @ref, msg}
    end
  end

  def restart(registerd_info) do
    case Hook.restart(module: registerd_info.name) do
      {:ok, :restart, msg} -> {:ok, @ref, msg}
      {:error, :restart, msg} -> {:error, @ref, msg}
    end
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{id: "#{__MODULE__}"}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state, 300}
  end

  def handle_info(:timeout, state) do
    # We should w8 for completing PubSub
    if is_nil(Process.whereis(MishkaHtml.PubSub)) do
      {:noreply, state, 100}
    else
      initial([])
      {:noreply, state}
    end
  end
end
