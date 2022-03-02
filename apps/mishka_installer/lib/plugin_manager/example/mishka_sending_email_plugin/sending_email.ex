defmodule MsihkaSendingEmailPlugin.SendingEmail do

  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: MishkaInstaller.Reference.OnUserAfterLogin,
      event: :on_user_after_login,
      initial: []

  def initial(args) do
    Logger.info("SendingEmail plugin was started")
    event = %PluginState{name: "MsihkaSendingEmailPlugin.SendingEmail", event: Atom.to_string(@ref), priority: 100}
    Hook.register(event: event)
    {:ok, @ref, args}
  end

  def call(%MishkaInstaller.Reference.OnUserAfterLogin{} = _data) do
    # TODO: this Call function should be used with hook
    # TODO: should we have a halt status to terminate all the programes?
    # TODO: send an email without changing state
    # TODO: store a log for activities
    # {:reply, new_state} | {:noreply, :halt}
  end

  def stop(%PluginState{} = registerd_info) do
    case Hook.stop(module: registerd_info.name) do
      {:ok, :stop, msg} -> {:ok, @ref, msg}
      {:error, :stop, msg} -> {:error, @ref, msg}
    end
  end

  def restart(%PluginState{} = registerd_info) do
    case Hook.restart(module: registerd_info.name) do
      {:ok, :restart, msg} -> {:ok, @ref, msg}
      {:error, :restart, msg} -> {:error, @ref, msg}
    end
  end
end
