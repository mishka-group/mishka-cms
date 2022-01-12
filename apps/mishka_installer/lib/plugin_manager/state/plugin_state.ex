defmodule MishkaInstaller.PluginState do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaInstaller.PluginStateDynamicSupervisor, as: PSupervisor
  alias __MODULE__
  # TODO: if each plugin is down or has error, what we should do?

  @type params() :: map()
  @type id() :: String.t()
  @type module_name() :: atom()
  @type event_name() :: atom()
  @type event() :: atom()
  @type plugin() :: %PluginState{
    name: atom(),
    event: event(),
    priority: integer(),
    status: :started | :stopped | :restarted,
    depend_type: :soft | :hard,
    depends: [module()]
  }

  defstruct [:name, :event, priority: 1, status: :started, depend_type: :soft, depends: []]

  def start_link(args) do
    {id, type} = {Map.get(args, :id), Map.get(args, :type)}
    GenServer.start_link(__MODULE__, default(id), name: via(id, type))
  end

  defp default(module_name) do
    %PluginState{name: module_name}
  end

  @spec save(plugin()) :: :ok | {:error, :save, any} | {:error, :save, :already_started, any}
  def save(element) do
    case PSupervisor.start_job(%{id: Map.get(element, :name), type: Map.get(element, :event)}) do
      {:ok, pid} ->
        GenServer.cast(pid, {:push, element})
        {:ok, :save, element}
      {:ok, pid, _any} ->
        GenServer.cast(pid, {:push, element})
      {:error, {:already_started, pid}} ->  {:error, :save, :already_started, pid}
      {:error, result} ->  {:error, :save, result}
    end
  end

  def get(module: module_name) do
    case PSupervisor.get_plugin_pid(module_name) do
      {:ok, :get_plugin_pid, pid} ->
        GenServer.call(pid, {:pop, :module})
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
      {:error, :get_plugin_pid} -> {:error, :get, :not_found}
    end
  end

  def delete(event: event_name) do
    PSupervisor.running_imports(event_name) |> Enum.map(&delete(module: &1.id))
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
  def init(state) do
    Logger.info("OTP Plugin state server was started")
    {:ok, state}
  end

  @impl true
  def handle_call({:pop, :module}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, element}, _state) do
    {:noreply, element}
  end

  @impl true
  def handle_cast({:stop, :module}, state) do
    new_state = Map.merge(state, %{status: :stopped})
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:delete, :module}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
  end

  defp via(id, value) do
    {:via, Registry, {MishkaInstaller.PluginStateRegistry, id, value}}
  end
end
