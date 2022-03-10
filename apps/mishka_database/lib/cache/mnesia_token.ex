defmodule MishkaDatabase.Cache.MnesiaToken do
  use GenServer
  alias :mnesia, as: Mnesia
  require Logger

  @timeout 5000
  @delete_tokens :timer.seconds(360)
  @save_refresh :timer.seconds(10)

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def save(token_id, user_id, token, exp, create_time, os) do
    GenServer.cast(__MODULE__, {:push, token_id, user_id, token, exp, create_time, os})
  end

  def save_different_node(token_id, user_id, token, exp, create_time, os) do
    Process.send_after(__MODULE__, {:push, token_id, user_id, token, exp, create_time, os}, @save_refresh)
  end

  def get_token_by_user_id(user_id) do
    GenServer.call(__MODULE__, {:get_token_by_user_id, user_id}, @timeout)
  end

  def get_token_by_id(id) do
    GenServer.call(__MODULE__, {:get_token_by_id, id}, @timeout)
  end

  def delete_token(token) do
    GenServer.cast(__MODULE__, {:delete_token, token})
  end

  def delete_expierd_token(user_id) do
    GenServer.cast(__MODULE__, {:delete_expierd_token, user_id})
  end

  def delete_all_user_tokens(user_id) do
    GenServer.cast(__MODULE__, {:delete_all_user_tokens, user_id})
  end

  def delete_all_tokens() do
    GenServer.call(__MODULE__, {:delete_all_tokens})
  end

  def get_all_token() do
    GenServer.call(__MODULE__, {:get_all_token})
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end


  @impl true
  def init(state) do
    Logger.info("MnesiaToken OTP server was started")
    {:ok, state, {:continue, :start_mnesia_token}}
  end


  @impl true
  def handle_continue(:start_mnesia_token, state) do
    start_token()
    Process.send_after(__MODULE__, :reject_all_expired_tokens, @delete_tokens)
    {:noreply, state}
  end


  @impl true
  def handle_call({:get_token_by_id, id}, _from, state) do
    data_to_read = fn ->
      Mnesia.read({Token, id})
    end

    token_selected = case Mnesia.transaction(data_to_read) do
      {:atomic,[{Token, id, user_id, token, exp, create_time, os}]} ->

        %{
          id: id,
          user_id: user_id,
          token: token,
          access_expires_in: exp,
          create_time: create_time,
          os: os
        }

      {:atomic, []} ->  %{}
      _ -> %{}
    end

    {:reply, token_selected, state}
  end

  def handle_call({:get_all_token}, _from, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:reply, %{}, state}
      {:atomic, data} -> {:reply, data, state}
      _ -> {:reply, %{}, state}
    end
  end


  @impl true
  def handle_call({:get_token_by_user_id, user_id}, _from, state) do
    token_selected = Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> %{}
      {:atomic, data} -> data
      _ -> %{}
    end

    {:reply, token_selected, state}
  end


  @impl true
  def handle_call({:delete_all_tokens}, _from, state) do
    all_token = Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> state
      {:atomic, data} ->

        Enum.map(data, fn [id, _user_id, _token, _access_expires_in, _create_time, _os] ->
          Mnesia.dirty_delete(Token, id)
        end)

        state
      _ -> state
    end

    {:reply, all_token, state}
  end

  @impl true
  def handle_cast({:delete_token, token}, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$3", "#{token}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:noreply, state}
      {:atomic, data} ->
        Enum.map(data, fn [id, _user_id, _token, _exp_time, _create_time, _os] -> Mnesia.dirty_delete(Token, id) end)
        {:noreply, state}
      _ -> {:noreply, state}
    end
  end


  @impl true
  def handle_cast({:delete_expierd_token, user_id}, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:noreply, state}
      {:atomic, data} ->

        Enum.map(data, fn [id, _user_id, _token, access_expires_in, _create_time, _os] ->
          if access_expires_in <= System.system_time(:second) do
            Mnesia.dirty_delete(Token, id)
          end
        end)

        {:noreply, state}
      _ -> {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:delete_all_user_tokens, user_id}, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:noreply, state}
      {:atomic, data} ->
        Enum.map(data, fn [id, _user_id, _token, _access_expires_in, _create_time, _os] -> Mnesia.dirty_delete(Token, id) end)
        {:noreply, state}
      _ -> {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:push, token_id, user_id, token, exp, create_time, os}, state) do
    fn ->
      Mnesia.write({Token, token_id, user_id, token, exp, create_time, os})
    end
    |> Mnesia.transaction()

    Logger.info("Token of MnesiaToken OTP server was created or updated")
    {:noreply, state}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("MnesiaToken server was stoped and clean State")
    {:stop, :normal, stats}
  end

  @impl true
  def handle_info(:reject_all_expired_tokens,  state) do
    Logger.info("OTP Reject all expired tokens server into Mnesia was started")
    Process.send_after(__MODULE__, :reject_all_expired_tokens, @delete_tokens)

    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:noreply, state}
      {:atomic, data} ->
        Enum.map(data, fn [id, _user_id, _token, access_expires_in, _create_time, _os] ->
          if access_expires_in <= System.system_time(:second) do
            Mnesia.dirty_delete(Token, id)
          end
        end)
        {:noreply, state}

      _ -> {:noreply, state}
    end
  end

  def handle_info({:push, token_id, user_id, token, exp, create_time, os},  state) do
    fn ->
      Mnesia.write({Token, token_id, user_id, token, exp, create_time, os})
    end
    |> Mnesia.transaction()

    Logger.info("Refresh Token was saved on background")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    if reason != :normal do
      Logger.warn("Reason of Terminate #{inspect(reason)} and State is #{inspect(state)}")
    end
    # TODO: send error to log server
  end

  defp start_token() do
    Mnesia.create_schema([node()])
    Mnesia.start()
    case Mnesia.create_table(Token, [disc_only_copies: [node()], attributes: [:id, :user_id, :token, :access_expires_in, :create_time, :os]]) do
      {:atomic, :ok} ->
        Mnesia.add_table_index(Token, :user_id)
        Logger.info("Table of MnesiaToken OTP server was created")

      {:aborted, {:already_exists, Token}} ->
        check_token_table()

      {:aborted, {:bad_type, Token, :disc_only_copies, :nonode@nohost}} ->
        Logger.info("MnesiaToken was recreated")
        Mnesia.stop()
        start_token()
      _n ->
        check_token_table()
    end
  end


  defp check_token_table() do
    case Mnesia.table_info(Token, :attributes) do
      {:aborted, {:no_exists, Token, :attributes}} -> {:error, :start_mnesia_token, :no_exists}

      [:id, :user_id, :token, :access_expires_in, :create_time, :os] ->

        Mnesia.wait_for_tables([Token], 5000)


        Mnesia.transform_table(Token,
          fn ({Token, id, user_id, token, access_expires_in, create_time, os}) ->
            {Token, id, user_id, token, access_expires_in, create_time, os}
          end,
          [:id, :user_id, :token, :access_expires_in, :create_time, :os]
        )

        Mnesia.add_table_index(Token, :user_id)
        Logger.info("Table transforming of MnesiaToken OTP server was started")

      other ->
        Logger.warning("Error of Mnesia Token: #{inspect(other)}")

        {:error, other}
    end
  end

end
