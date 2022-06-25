defmodule MishkaUser.Token.TokenManagemnt do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaDatabase.Cache.MnesiaToken
  @ets_table :user_token_ets_state

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

  ##########################################
  # 1. create handle_info to delete expired token every 24 hours with Registery
  ##########################################


  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def save(user_token, user_id) do
    save_token_on_disk(user_token)
    ETS.Set.put!(table(), {String.to_atom(user_token.token_info.token_id), user_id, user_token.token_info})
  end

  def get_all(user_id) do
    ETS.Set.match!(table(), {:_, user_id, :"$3"})
    |> Enum.map(&List.first/1)
  rescue
    _ -> []
  end

  def get_all() do
    ETS.Set.to_list!(table())
  end

  def delete(token_id: token_id) do
    ETS.Set.delete(table(), String.to_atom(token_id))
  end

  def delete(user_id) do
    # TODO: delete all the token of mnesia => refresh
    ETS.Set.match_delete(table(), {:_, user_id, :_})
  end

  def delete_token(user_id, token) do
    # TODO: delete all the token of mnesia => refresh
    ETS.Set.match_delete(table(), {:_, user_id, %{token: token}})
    get_all(user_id)
  end

  def delete_child_token(user_id, refresh_token) do
    case get_token(user_id, refresh_token) do
      nil -> nil
      user_token ->
        delete(token_id: user_token.token_id)
        ETS.Set.match_delete(table(), {:_, user_id, %{rel: user_token.token_id}})
    end
  end

  def get_token(user_id, token) do
    # TODO: update update_last_used System.system_time(:second)
    case ETS.Set.match_object(table(), {:"$1", user_id, %{token: token}}) do
      {:ok, [{_token_id, ^user_id, token_info}]} ->
        # TODO: update update_last_used System.system_time(:second)
        token_info
      _ -> nil
    end
  end

  @spec count_refresh_token(id()) :: {:error, :count_refresh_token} | {:ok, :count_refresh_token}
  def count_refresh_token(user_id) do
    case ETS.Set.match(table(), {:"$1", user_id, %{type: "refresh"}}) do
      {:ok, devices} when is_list(devices) and length(devices) <= 5 -> {:ok, :count_refresh_token}
      _ -> {:error, :count_refresh_token}
      end
  end

  # Callbacks
  @impl true
  def init(state) do
    Logger.info("Token OTP server was started")
    # TODO: sync Mnesia token with ets MnesiaToken.get_token_by_user_id(user_id)
    # TODO: delete expierd token from ets
    # TODO: delete expierd token from mnesia
    # TODO: after rejection mnesia and ets chech is there any token for user if not so do MishkaUser.Acl.AclManagement.stop(item.id) and MishkaContent.Cache.BookmarkManagement.stop(item.id)
    table = ETS.Set.new!(name: @ets_table,protection: :public,read_concurrency: true,write_concurrency: true)
    {:ok, Map.merge(state, %{set: table})}
  end

  @impl true
  def terminate(reason, _state) do
    # TODO: it needs activity log
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

  defp save_token_on_disk(%{id: user_id, token_info: %{type: "refresh"} = token_info}) do
    MnesiaToken.save_different_node(
      token_info.token_id,
      user_id,
      token_info.token,
      token_info.access_expires_in,
      token_info.create_time,
      token_info.os
    )
  end

  defp save_token_on_disk(user_token), do: user_token
end
