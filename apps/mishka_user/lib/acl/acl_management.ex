defmodule MishkaUser.Acl.AclManagement do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaUser.Acl.AclDynamicSupervisor

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

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
  def handle_info({:update_user_permissions, _user_id}, state) do
    # update user permissions on otp state
    {:noreply, state}
  end

  @impl true
  def handle_info({:update_role, _role_id}, state) do
    # get all online user which has ACL state
    # check the have this role_id
    # then send a node to update_user_permissions again
    {:noreply, state}
  end

  @impl true
  def handle_info({:delete_role, _role_id}, state) do
    # search all the user are online get thire ides (on ACL state)
    # query to database where role id is same
    # input thire user ides to a list
    # then delete the role after this
    # send a node to update_user_permissions to update again
    {:noreply, state}
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
