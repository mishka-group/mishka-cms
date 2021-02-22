defmodule MishkaDatabase.Cache.MnesiaToken do
  use GenServer
  alias :mnesia, as: Mnesia
  require Logger

  ##########################################
  # 1. create handle info to delete expired token every 24 hours with stream lazy load map
  # 2. we dont need any state then just keep starter state
  ##########################################


  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end


  def save(token_id, user_id, token, exp, create_time, os) do
      GenServer.cast(__MODULE__, {:push, token_id, user_id, token, exp, create_time, os})
  end

  def get_token_by_user_id(user_id) do
    GenServer.call(__MODULE__, {:get_token_by_user_id, user_id})
  end

  def get_token_by_id(id) do
    GenServer.call(__MODULE__, {:get_token_by_id, id})
  end

  def get_all_token() do
    GenServer.call(__MODULE__, {:get_all_token})
  end

  def delete_token(token) do
    GenServer.call(__MODULE__, {:delete_token, token})
  end

  def delete_expierd_token(user_id) do
    GenServer.call(__MODULE__, {:delete_expierd_token, user_id})
  end

  def delete_all_user_tokens(user_id) do
    GenServer.call(__MODULE__, {:delete_all_user_tokens, user_id})
  end


  @impl true
  def init(state) do
    Logger.info("MnesiaToken OTP server was started")
    {:ok, state, {:continue, :start_mnesia_token}}
  end


  @impl true
  def handle_continue(:start_mnesia_token, state) do
    start_token()
    {:noreply, state}
  end


  @impl true
  def handle_call({:get_token_by_id, id}, _from, state) do
    data_to_read = fn ->
      Mnesia.read({Token, id})
    end

    case Mnesia.transaction(data_to_read) do
      {:atomic,[{Token, id, user_id, token, exp, create_time, os}]} ->

        {:reply, %{id: id, user_id: user_id, token: token, access_expires_in: exp, create_time: create_time, os: os}, state}

      {:atomic, []} ->  {:reply, %{}, state}
      _ -> {:reply, %{}, state}
    end
  end


  @impl true
  def handle_call({:get_token_by_user_id, user_id}, _from, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:reply, %{}, state}
      {:atomic, data} -> {:reply, data, state}
      _ -> {:reply, %{}, state}
    end
  end


  @impl true
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
  def handle_call({:delete_token, token}, _from, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$3", "#{token}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:reply, %{}, state}
      {:atomic, data} ->
        Enum.map(data, fn [id, _user_id, _token, _exp_time, _create_time, _os] -> Mnesia.dirty_delete(Token, id) end)
        {:reply, data, state}
      _ -> {:reply, %{}, state}
    end
  end


  @impl true
  def handle_call({:delete_expierd_token, user_id}, _from, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:reply, %{}, state}
      {:atomic, data} ->

        Enum.map(data, fn [id, _user_id, _token, access_expires_in, _create_time, _os] ->
          if access_expires_in <= System.system_time(:second) do
            Mnesia.dirty_delete(Token, id)
          end
        end)

        {:reply, data, state}
      _ -> {:reply, %{}, state}
    end
  end

  @impl true
  def handle_call({:delete_all_user_tokens, user_id}, _from, state) do
    Mnesia.transaction(fn ->
      Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}])
    end)
    |> case do
      {:atomic, []} -> {:reply, %{}, state}
      {:atomic, data} ->
        Enum.map(data, fn [id, _user_id, _token, _access_expires_in, _create_time, _os] -> Mnesia.dirty_delete(Token, id) end)
        {:reply, data, state}
      _ -> {:reply, %{}, state}
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



  defp start_token() do
    Mnesia.create_schema([node()])
    Mnesia.start()
    case Mnesia.create_table(Token, [disc_only_copies: [node()], attributes: [:id, :user_id, :token, :access_expires_in, :create_time, :os]]) do
      {:atomic, :ok} ->
        Mnesia.add_table_index(Token, :user_id)
        Logger.info("Table of MnesiaToken OTP server was created")

      {:aborted, {:already_exists, Token}} ->
        check_token_table()

      _ ->
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















# test
# alias :mnesia, as: Mnesia ; token_list = Mnesia.transaction(fn -> Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [], [:"$$"]}]) end)

# fn -> Mnesia.write({Token, 1, 1, "token", "exp", "create_time", "os"}) end |> Mnesia.transaction()
