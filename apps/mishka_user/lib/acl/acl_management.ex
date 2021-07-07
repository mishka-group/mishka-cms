defmodule MishkaUser.Acl.AclManagement do
  use GenServer
  require Logger
  alias MishkaUser.Acl.AclDynamicSupervisor

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

  ##########################################
  # 1. create handle_info to delete expired Acl every 24 hours with Registery
  ##########################################
  def test(id) do
    # GenServer.call(via(id, "user_permission"), :pop)
    {:ok, :get_user_pid, pid} = AclDynamicSupervisor.get_user_pid(id)
    IO.inspect(pid)
    GenServer.call(pid, :pop)
    # DynamicSupervisor.terminate_child(MishkaUser.Acl.AclOtpRunner, pid)
  end

  def start_link(args) do
    id = Keyword.get(args, :id)
    type = Keyword.get(args, :type)

    GenServer.start_link(__MODULE__, default(id), name: via(id, type))
  end

  defp default(user_id) do
    %{id: user_id, user_permission: []}
  end

  @spec save(params(), id()) :: :ok
  def save(element, user_id) do
    with {:ok, :get_user_pid, pid} <- AclDynamicSupervisor.get_user_pid(user_id) do
      GenServer.cast(pid, {:push, element})
    else
      {:error, :get_user_pid} ->
        AclDynamicSupervisor.start_job([id: user_id, type: "user_permission"])
        save(element, user_id)
    end
  end

  @spec get_all(id()) :: any
  def get_all(user_id) do
    with {:ok, :get_user_pid, pid} <- AclDynamicSupervisor.get_user_pid(user_id) do
      GenServer.call(pid, :pop)
    else
      {:error, :get_user_pid} ->
        AclDynamicSupervisor.start_job([id: user_id, type: "user_permission"])
        get_all(user_id)
    end
  end

  @spec delete(id()) :: any
  def delete(user_id) do
    with {:ok, :get_user_pid, pid} <- AclDynamicSupervisor.get_user_pid(user_id) do
      GenServer.call(pid, :delete)
    else
      {:error, :get_user_pid} ->
        AclDynamicSupervisor.start_job([id: user_id, type: "user_permission"])
        delete(user_id)
    end
  end

  @spec stop(id()) :: :ok
  def stop(user_id) do
    with {:ok, :get_user_pid, pid} <- AclDynamicSupervisor.get_user_pid(user_id) do
      GenServer.cast(pid, :stop)
    else
      {:error, :get_user_pid} ->
        AclDynamicSupervisor.start_job([id: user_id, type: "user_permission"])
        stop(user_id)
    end
  end

  # Callbacks

  @impl true
  def init(state) do
    Logger.info("ACL OTP server was started")
    {:ok, state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, element}, _state) do
    {:noreply, element}
  end

  @impl true
  def handle_cast(:delete, _state) do
    {:noreply, %{}}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP ACL server was stoped and clean State")
    {:stop, :normal, stats}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
    # send error to log server
  end

  defp via(key, value) do
    {:via, Registry, {MishkaUser.Acl.AclRegistry, key, value}}
  end
end
