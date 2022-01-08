defmodule MishkaInstaller.PluginState do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaInstaller.PluginStateDynamicSupervisor, as: Supervisor

  # TODO: if each plugin is down or has error, what we should do?

  @type params() :: map()
  @type id() :: String.t()

  defstruct [:name, :module, :priority, :status, :depend_type, :depends]

  def start_link(args) do
    {id, type} = {Keyword.get(args, :id), Keyword.get(args, :type)}
    GenServer.start_link(__MODULE__, default(id), name: via(id, type))
  end

  defp default(event_name) do
    %{id: event_name}
  end

  def save(_element, _module_name, _event_name) do
    # Supervisor.start_job(%{id: module_name, type: event_name})
    # GenServer.cast(pid, {:push, element, module_name, event_name})
  end

  def get(module: module_name) do
    {:ok, :get_plugin_pid, pid} = Supervisor.get_plugin_pid(module_name)
    GenServer.call(pid, {:pop, :module, module_name})
  end

  def get_all(event: _event_name) do
    # Supervisor.get_user_pid(user_id)
    # GenServer.call(pid, {:pop, :event, event_name})
  end

  def get_all() do
    # Supervisor.get_user_pid(user_id)
    # GenServer.call(pid, {:pop, :events})
  end

  def delete(module: _module_name) do
    # Supervisor.get_user_pid(user_id)
    # GenServer.cast(pid, {:delete, :module, module_name})
  end

  def delete(event: _event_name) do
    # Supervisor.get_user_pid(user_id)
    # GenServer.cast(pid, {:delete, :event, event_name})
  end

  def stop(module: _module_name)  do
    # Supervisor.get_user_pid(user_id)
    # GenServer.cast(pid, {:stop, :module, module_name})
  end

  def stop(event: _event_name) do
    # Supervisor.get_user_pid(user_id)
    # GenServer.cast(pid, {:stop, :event, event_name})
  end


  # Callbacks
  @impl true
  def init(state) do
    Logger.info("OTP Plugin state server was started")
    {:ok, state}
  end

  @impl true
  def handle_call({:pop, :module, _module_name}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:pop, :event, _event_name}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:pop, :events}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, _element, _module_name, _event_name}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete, :module, _module_name}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast({:delete, :event, _event_name}, state) do
    Logger.info("OTP Plugin state server was stoped and clean State")
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast({:stop, :module, _module_name}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:stop, :event, _event_name}, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
  end

  defp via(id, value) do
    {:via, Registry, {MishkaContent.Cache.BookmarkRegistry, id, value}}
  end

end
