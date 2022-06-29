defmodule MishkaUser.Acl.AclManagement do
  use GenServer, restart: :temporary
  require Logger

  @ets_table :acl_ets_state

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()


  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def save(element, user_id) do
    ETS.Set.put!(table(), {user_id, element})
  end

  @spec get_all(id()) :: any
  def get_all(user_id) do
    case ETS.Set.get(table(), user_id) do
      {:ok, {user_id, element}} ->
        %{id: user_id, user_permission: element.user_permission, created: element.created}
      _ ->
        user_permission = MishkaUser.User.permissions(user_id)
        created = System.system_time(:second)
        save(
          %{
            id: user_id,
            user_permission: user_permission,
            created: created
          },
          user_id
        )
        %{id: user_id, user_permission: user_permission, created: created}
    end
  end

  @spec delete(id()) :: any
  def delete(user_id) do
    ETS.Set.delete(table(), user_id)
  end

  @spec stop() :: :ok
  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  # Callbacks
  @impl true
  def init(_state) do
    Logger.info("ACL OTP server was started")
    table =
      ETS.Set.new!(
        name: @ets_table,
        protection: :public,
        read_concurrency: true,
        write_concurrency: true
      )
    {:ok, %{set: table}, 100}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP ACL server was stoped and clean State")
    {:stop, :normal, stats}
  end

  # TODO: suscribe to role and permetion and update user data
  @impl true
  def handle_info({:role, :ok, _action, repo_data}, state) do
    Logger.warn("Your ETS state of setting is going to be updated")
    {:ok, records} = MishkaUser.Acl.UserRole.roles(repo_data.id)
    Enum.map(records, fn x ->
      # Delete acl of user from ets
      delete(x.user_id)
      # Clean user refresh token from database
      MishkaUser.Token.UserToken.delete_by_user_id(x.user_id)
      # Clean user all token from ets
      MishkaUser.Token.TokenManagemnt.delete(x.user_id)
    end)
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, state) do
    cond do
      !is_nil(MishkaInstaller.get_config(:pubsub)) &&
          is_nil(Process.whereis(MishkaInstaller.get_config(:pubsub))) ->
        {:noreply, state, 100}

      true ->
        MishkaUser.Acl.Role.subscribe()
        # TODO: subscribe to permition database
        {:noreply, state}
    end
  end

  @impl true
  def terminate(reason, _state) do
    if reason != :normal do
      Logger.warn("Reason of Terminate #{inspect(reason)}")
    end
  end

  defp table() do
    case ETS.Set.wrap_existing(@ets_table) do
      {:ok, set} -> set
      _ ->
        start_link([])
        table()
    end
  end
end
