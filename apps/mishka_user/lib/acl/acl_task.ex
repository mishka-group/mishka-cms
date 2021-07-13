defmodule MishkaUser.Acl.AclTask do
  use GenServer
  require Logger

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def update_role(role_id) do
    GenServer.cast(__MODULE__, {:update_role, role_id})
  end

  def delete_role(role_id) do
    GenServer.cast(__MODULE__, {:delete_role, role_id})
  end

  @impl true
  def init(state) do
    Logger.info("OTP ACLTask server was started")
    {:ok, state}
  end

  @impl true
  def handle_cast({:update_role, role_id}, state) do
    {:ok, records} = MishkaUser.Acl.UserRole.roles(role_id)
    Enum.map(records, fn x ->
      case MishkaUser.Acl.AclDynamicSupervisor.get_user_pid(x.user_id) do
        {:ok, :get_user_pid, pid} ->
          Process.send_after(pid, {:update_user_permissions, x.user_id}, 100)
          x.user_id
        _ -> nil
      end
    end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete_role, role_id}, state) do
    {:ok, records} = MishkaUser.Acl.UserRole.roles(role_id)
    Enum.map(records, fn x ->
      case MishkaUser.Acl.AclDynamicSupervisor.get_user_pid(x.user_id) do
        {:ok, :get_user_pid, _pid} ->
          MishkaUser.Acl.AclManagement.stop(x.user_id)
          x.user_id
        _ -> nil
      end
    end)
    {:noreply, state}
  end

end
