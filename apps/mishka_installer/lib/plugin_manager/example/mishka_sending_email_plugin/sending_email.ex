defmodule MsihkaSendingEmailPlugin.SendingEmail do

  alias MishkaInstaller.Reference.OnUserAfterLogin
  use MishkaInstaller.Hook,
      module: __MODULE__,
      behaviour: OnUserAfterLogin,
      event: :on_user_after_login,
      initial: []

  def initial(args) do
    Logger.info("SendingEmail plugin was started")
    event = %PluginState{name: "MsihkaSendingEmailPlugin.SendingEmail", event: Atom.to_string(@ref), priority: 100}
    Hook.register(event: event)
    {:ok, @ref, args}
  end

  def call(%OnUserAfterLogin{} = state) do
    IO.inspect(state)
    {:reply, state}
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
