defmodule MishkaInstaller.PluginStateDynamicSupervisor do


  @spec start_job(map()) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_job(args) do
    DynamicSupervisor.start_child(MishkaInstaller.Cache.PluginStateOtpRunner, {MishkaInstaller.PluginState, args})
  end


  def running_imports(), do: registery()

  def running_imports(event_name) do
    [{:"==", :"$3", event_name}]
    |> registery()
  end

  defp registery(guards \\ []) do
    {match_all, map_result} =
      {
        {:"$1", :"$2", :"$3"},
        [%{id: :"$1", pid: :"$2", type: :"$3"}]
      }
    Registry.select(MishkaInstaller.PluginStateRegistry, [{match_all, guards, map_result}])
  end

  @spec get_plugin_pid(String.t()) :: {:error, :get_plugin_pid} | {:ok, :get_plugin_pid, pid}
  def get_plugin_pid(module_name) do
    case Registry.lookup(MishkaInstaller.PluginStateRegistry, module_name) do
      [] -> {:error, :get_plugin_pid}
      [{pid, _type}] -> {:ok, :get_plugin_pid, pid}
    end
  end
end
