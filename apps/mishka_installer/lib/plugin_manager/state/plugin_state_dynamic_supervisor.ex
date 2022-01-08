defmodule MishkaInstaller.PluginStateDynamicSupervisor do

  @spec start_job(map()) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_job(args) do
    DynamicSupervisor.start_child(MishkaInstaller.Cache.PluginStateOtpRunner, {MishkaInstaller.PluginState, args})
  end

  @spec running_imports :: [any]
  def running_imports() do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:"==", :"$3", "plugin_state"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(MishkaInstaller.PluginStateRegistry, [{match_all, guards, map_result}])
  end


  @spec get_plugin_pid(String.t()) :: {:error, :get_plugin_pid} | {:ok, :get_plugin_pid, pid}
  def get_plugin_pid(user_id) do
    case Registry.lookup(MishkaInstaller.PluginStateRegistry, user_id) do
      [] -> {:error, :get_plugin_pid}
      [{pid, _type}] -> {:ok, :get_plugin_pid, pid}
    end
  end
end
