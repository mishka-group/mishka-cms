defmodule MishkaInstaller.PluginState do
  use GenServer
  require Logger
  alias MishkaInstaller.PluginStateDynamicSupervisor, as: PSupervisor
  alias MishkaInstaller.Plugin
  alias __MODULE__

  defstruct [:name, :event, priority: 1, status: :started, depend_type: :soft, depends: [], extra: []]

  @type params() :: map()
  @type id() :: String.t()
  @type module_name() :: String.t()
  @type event_name() :: String.t()
  @type plugin() :: %PluginState{
    name: module_name(),
    event: event_name(),
    priority: integer(),
    status: :started | :stopped | :restarted,
    depend_type: :soft | :hard,
    depends: list(String.t()),
    extra: list(map())
  }
  @type t :: plugin()

  def start_link(args) do
    {id, type} = {Map.get(args, :id), Map.get(args, :type)}
    GenServer.start_link(__MODULE__, default(id, type), name: via(id, type))
  end

  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient,
      max_restarts: 4
    }
  end

  defp default(plugin_name, event) do
    %PluginState{name: plugin_name, event: event}
  end

  @spec push(MishkaInstaller.PluginState.t()) :: :ok | {:error, :push, any}
  def push(%PluginState{} = element) do
    case PSupervisor.start_job(%{id: element.name, type: element.event}) do
      {:ok, status, pid} -> GenServer.cast(pid, {:push, status, element})
      {:error, result} ->  {:error, :push, result}
    end
  end

  @spec push_call(MishkaInstaller.PluginState.t()) :: :ok | {:error, :push, any}
  def push_call(%PluginState{} = element) do
    case PSupervisor.start_job(%{id: element.name, type: element.event}) do
      {:ok, status, pid} ->
        if Mix.env() == :test, do: Logger.warn("Plugin State of #{element.name} is being pushed")
        GenServer.call(pid, {:push, status, element})
      {:error, result} ->  {:error, :push, result}
    end
  end

  @spec get([{:module, module_name()}]) :: plugin() | {:error, :get, :not_found}
  def get(module: module_name) do
    case PSupervisor.get_plugin_pid(module_name) do
      {:ok, :get_plugin_pid, pid} -> GenServer.call(pid, {:pop, :module})
      {:error, :get_plugin_pid} -> {:error, :get, :not_found}
    end
  end

  def get_all(event: event_name) do
    PSupervisor.running_imports(event_name) |> Enum.map(&get(module: &1.id))
  end

  def get_all() do
    PSupervisor.running_imports() |> Enum.map(&get(module: &1.id))
  end

  def delete(module: module_name) do
    case PSupervisor.get_plugin_pid(module_name) do
      {:ok, :get_plugin_pid, pid} ->
        GenServer.cast(pid, {:delete, :module})
        {:ok, :delete}
      {:error, :get_plugin_pid} -> {:error, :delete, :not_found}
    end
  end

  def delete(event: event_name) do
    PSupervisor.running_imports(event_name) |> Enum.map(&delete(module: &1.id))
  end

  def delete_child(module: module_name) do
    case PSupervisor.get_plugin_pid(module_name) do
      {:ok, :get_plugin_pid, pid} -> DynamicSupervisor.terminate_child(PluginStateOtpRunner, pid)
      {:error, :get_plugin_pid} -> {:error, :delete, :not_found}
    end
  end

  def terminate_all_pids() do
    Enum.map(PSupervisor.running_imports(), fn item ->
      GenServer.cast(item.pid, {:delete, :module})
    end)
  end
  def stop(module: module_name)  do
    case PSupervisor.get_plugin_pid(module_name) do
      {:ok, :get_plugin_pid, pid} ->
        GenServer.cast(pid, {:stop, :module})
        {:ok, :stop}
      {:error, :get_plugin_pid} -> {:error, :stop, :not_found}
    end
  end

  def stop(event: event_name) do
    PSupervisor.running_imports(event_name) |> Enum.map(&stop(module: &1.id))
  end

  # Callbacks
  @impl true
  def init(%PluginState{} = state) do
    Logger.info("#{Map.get(state, :name)} from #{Map.get(state, :event)} event of Plugins manager system was started")
    {:ok, state, {:continue, {:sync_with_database, :take}}}
  end

  @impl true
  def handle_call({:pop, :module}, _from, %PluginState{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:push, _status, %PluginState{} = element}, _from, %PluginState{} = _state) do
    element
    |> Map.from_struct()
    |> Plugin.add_or_edit_by_name()
    {:reply, element, element}
  end

  @impl true
  def handle_cast({:push, status, %PluginState{} = element}, _state) do
    {:noreply, element, {:continue, {:sync_with_database, status}}}
  end

  @impl true
  def handle_cast({:stop, :module}, %PluginState{} = state) do
    new_state = Map.merge(state, %{status: :stopped})
    {:noreply, new_state, {:continue, {:sync_with_database, :edit}}}
  end

  @impl true
  def handle_cast({:delete, :module}, %PluginState{} = state) do
    MishkaInstaller.plugin_activity("destroy", state, "high", "report")
    {:stop, :normal, state}
  end

  @impl true
  def handle_continue({:sync_with_database, _status}, %PluginState{} = state) do
    state
    |> Map.from_struct()
    |> Plugin.add_or_edit_by_name()
    |> check_output(state)

    {:noreply, state}
  end

  @impl true
  def handle_continue({:sync_with_database, :take}, %PluginState{} = state) do
    state =
      case Plugin.show_by_name("#{state.name}") do
        {:ok, :get_record_by_field, _error_atom, record_info} ->
          struct(__MODULE__, Map.from_struct(record_info))
        {:error, _result, _error_atom} -> state
      end
    {:noreply, state}
  end

  @impl true
  def terminate(reason, %PluginState{} = state) do
    MishkaInstaller.plugin_activity("read", state, "high", "throw")
    if reason != :normal do
      Logger.warn(
        "#{Map.get(state, :name)} from #{Map.get(state, :event)} event of Plugins manager was Terminated,
        Reason of Terminate #{inspect(reason)}"
      )
    end
  end

  defp via(id, value) do
    {:via, Registry, {PluginStateRegistry, id, value}}
  end

  defp check_output({:error, status, _, _} = _output, %PluginState{} = state) do
    MishkaInstaller.plugin_activity("#{status}", state, "high", "error")
  end

  defp check_output({:ok, status, _, _} = _output, %PluginState{} = state) do
    action = cond do
      status == :add -> "add"
      state.status == :stopped -> "delete"
      true -> "edit"
    end
    MishkaInstaller.plugin_activity(action, state, "high")
  end
end
