defmodule MsihkaSendingEmailPlugin.SendingSMS do
  # This module was just made for testing
  alias MsihkaSendingEmailPlugin.TestEvent
  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: TestEvent,
      event: :on_test_event,
      initial: []

  def initial(args) do
    Logger.info("SendingSMS plugin was started")
    event = %PluginState{name: "MsihkaSendingEmailPlugin.SendingSMS", event: Atom.to_string(@ref), priority: 1}
    Hook.register(event: event)
    {:ok, @ref, args}
  end

  def call(%TestEvent{} = state) do
    new_state = Map.merge(state, %{ip: "128.0.1.1"})
    {:reply, new_state}
  end

  def stop(%PluginState{} = registerd_info) do
    case Hook.stop(module: registerd_info.name) do
      {:ok, :stop, _msg} -> {:ok, @ref, registerd_info}
      {:error, :stop, msg} -> {:error, @ref, msg}
    end
  end

  def restart(%PluginState{} = registerd_info) do
    case Hook.restart(module: registerd_info.name) do
      {:ok, :restart, _msg} -> {:ok, @ref, registerd_info}
      {:error, :restart, msg} -> {:error, @ref, msg}
    end
  end
end
