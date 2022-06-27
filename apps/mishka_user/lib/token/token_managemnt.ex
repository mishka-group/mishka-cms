defmodule MishkaUser.Token.TokenManagemnt do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaUser.Token.UserToken
  @ets_table :user_token_ets_state

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def save(user_token, user_id) do
    # save_token_on_db(user_id, user_token)
      ETS.Bag.add!(
        table(),
        {user_id, user_token.token_info.token, user_token.token_info}
      )
  end

  def get_all(user_id) do
    ETS.Bag.lookup!(table(), user_id)
  rescue
    _ -> []
  end

  def get_all() do
    ETS.Bag.to_list!(table())
  end

  def delete(user_id) do
    UserToken.revaluation_user_token_as_stream(&UserToken.delete(&1.id), %{user_id: user_id})
    ETS.Bag.delete(table(), user_id)
  end

  def delete_token(user_id, token) do
    UserToken.revaluation_user_token_as_stream(&UserToken.delete(&1.id), %{token: token})
    ETS.Bag.match_delete(table(), {user_id, token, :_})
    get_all(user_id)
  end

  def delete_child_token(user_id, refresh_token) do
    case get_token(user_id, refresh_token) do
      nil ->
        nil

      user_token ->
        delete_token(user_id, user_token.token)
        ETS.Bag.match_delete(table(), {user_id, :_, %{rel: user_token.token_id}})
    end
  end

  def get_token(user_id, token) do
    ETS.Bag.lookup!(table(), user_id)
    |> Enum.find(fn {_user_id, user_token, _token_info} -> user_token == token end)
    |> case do
      data = {_user_id, _token, token_info} when not is_nil(data) ->
        save(
          %{token_info: Map.merge(token_info, %{last_used: System.system_time(:second)})},
          user_id
        )

        token_info

      _ ->
        nil
    end
  end

  # Ref: https://elixirforum.com/t/48598
  def delete_expire_token() do
    time = DateTime.utc_now() |> DateTime.to_unix()

    pattern = [
      {{:"$1", :"$2", :"$3"}, [{:<, {:map_get, :access_expires_in, :"$3"}, time}], [true]}
    ]

    ETS.Bag.select_delete(table(), pattern)
  end

  @spec count_refresh_token(id()) :: {:error, :count_refresh_token} | {:ok, :count_refresh_token}
  def count_refresh_token(user_id) do
    ETS.Bag.lookup!(table(), user_id)
    |> Enum.filter(fn {_user_id, _user_token, token_info} -> token_info.type == "refresh" end)
    |> length()
    |> case do
      devices when devices <= 5 -> {:ok, :count_refresh_token}
      _ -> {:error, :count_refresh_token}
    end
  end

  # Callbacks
  @impl true
  def init(state) do
    Logger.info("Token OTP server was started")

    bag =
      ETS.Bag.new!(
        name: @ets_table,
        protection: :public,
        duplicate: true,
        keypos: 1,
        read_concurrency: true,
        write_concurrency: true,
        compressed: false
      )

    {:ok, Map.merge(state, %{set: bag}), {:continue, :sync_with_database}}
  end

  @impl true
  def terminate(reason, _state) do
    # TODO: it needs activity log
    if reason != :normal do
      Logger.warn("Reason of Terminate #{inspect(reason)}")
    end
  end

  @impl true
  def handle_continue(:sync_with_database, state) do
    UserToken.revaluation_user_token_as_stream(
      &save(
        %{
          id: &1.user_id,
          token_info: %{
            token_id: &1.id,
            type: "refresh",
            token: &1.token,
            os: "linux",
            create_time: &1.inserted_at,
            last_used: &1.updated_at,
            access_expires_in: &1.expire_time |> DateTime.to_unix(),
            rel: nil
          }
        },
        &1.user_id
      ),
      %{expire_time: DateTime.utc_now()}
    )

    {:noreply, state}
  end

  defp table() do
    case ETS.Bag.wrap_existing(@ets_table) do
      {:ok, bag} ->
        bag

      _ ->
        start_link([])
        table()
    end
  end

  defp save_token_on_db(user_id, %{token_info: %{type: "refresh"} = token_info}) do
    Task.Supervisor.start_child(UserToken, fn ->
      UserToken.create(%{
        id: token_info.token_id,
        token: token_info.token,
        type: "refresh",
        expire_time: DateTime.from_unix(token_info.access_expires_in),
        extra: %{
          os: token_info.os,
          create_time: token_info.create_time
        },
        user_id: user_id
      })
    end)
  end

  defp save_token_on_db(user_token), do: user_token
end
