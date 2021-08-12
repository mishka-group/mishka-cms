defmodule MishkaUser.Token.TokenManagemnt do
  use GenServer, restart: :temporary

  @refresh_interval :timer.seconds(1) # :timer.seconds(5)
  @saving_interval :timer.seconds(300) # :timer.seconds(5)
  require Logger
  alias MishkaUser.Token.TokenDynamicSupervisor
  alias MishkaDatabase.Cache.MnesiaToken

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

  ##########################################
  # 1. create handle_info to delete expired token every 24 hours with Registery
  ##########################################


  def start_link(args) do
    id = Keyword.get(args, :id)
    type = Keyword.get(args, :type)

    GenServer.start_link(__MODULE__, default(id), name: via(id, type))
  end

  defp default(user_id) do
    [%{id: user_id, token_info: []}]
  end


  @spec save(params(), id()) :: :ok

  def save(element, user_id) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.cast(pid, {:push, element})
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        save(element, user_id)
    end
  end

  @spec get_all(id()) :: any
  def get_all(user_id) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.call(pid, :pop)
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        get_all(user_id)
    end
  end

  @spec delete(id()) :: any
  def delete(user_id) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.call(pid, :delete)
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        delete(user_id)
    end
  end

  @spec stop(id()) :: :ok
  def stop(user_id) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.cast(pid, :stop)
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        stop(user_id)
    end
  end

  @spec delete_token(id(), token()) :: any
  def delete_token(user_id, token) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.call(pid, {:delete, token})
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        delete_token(user_id, token)
    end
  end

  @spec delete_child_token(id(), token()) :: any
  def delete_child_token(user_id, refresh_token) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.call(pid, {:delete_child_token, refresh_token})
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        delete_child_token(user_id, refresh_token)
    end
  end

  @spec get_token(id(), token()) :: any
  def get_token(user_id, token) do
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(user_id) do
      schedule_delete_token(pid)
      GenServer.cast(pid, {:update_last_used, token})
      GenServer.call(pid, {:get_token, token})
    else
      {:error, :get_user_pid} ->
        TokenDynamicSupervisor.start_job([id: user_id, type: "token"])
        get_token(user_id, token)
    end
  end



  # Callbacks

  @impl true
  def init(state) do
    Logger.info("Token OTP server was started")
    with {:ok, :get_user_pid, pid} <- TokenDynamicSupervisor.get_user_pid(Keyword.get(state, :id)) do
      schedule_delete_token(pid)
    end
    {:ok, state, {:continue, :get_disc_token}}
  end

  @impl true
  def handle_continue(:get_disc_token, state) do
    user_id = List.first(state).id
    case MnesiaToken.get_token_by_user_id(user_id) do
      %{} ->
        Logger.info("There is no Saved Token for this user")
        {:noreply, state}

      data ->
        new_state = create_new_state_to_get_disc_token(data, user_id)

        {:noreply, [new_state]}
    end
  end


  @impl true
  def handle_call({:get_token, token}, _from, state) do
    token_map = get_token_info(state)
    |> Enum.find(fn x -> x.token == token end)

    {:reply, token_map, state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:delete, token}, _from, state) do
    new_token = get_token_info(state)
    |> Enum.reject(fn x -> x.token == token end)

    new_state = Enum.map(state, fn item ->
      Map.merge(
        item,
        %{
          id: item.id,
          token_info: new_token
        }
      )
    end)

    {:reply, state, new_state}
  end

  @impl true
  def handle_call({:delete_child_token, refresh_token}, _from, state) do
    {:reply, state, get_token_with_rel(refresh_token, state) }
  end

  @impl true
  def handle_cast({:push, element}, state) do
    first_list = List.first(element.token_info)

    if first_list.type == "refresh" do
      MnesiaToken.save_different_node(
        first_list.token_id,
        element.id,
        first_list.token,
        first_list.access_expires_in,
        first_list.create_time,
        first_list.os
      )
    end


    new_state =
      Enum.map(state, fn item ->
        token_info = item.token_info ++ element.token_info
        Map.merge(
          item,
          %{
            id: element.id,
            token_info: token_info
          }
        )
      end)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:delete, _state) do
    {:noreply, []}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP Token server was stoped and clean State")
    {:stop, :normal, stats}
  end

  @impl true
  def handle_cast({:update_last_used, token}, stats) do
    token_info = Enum.map(List.first(stats).token_info, fn x ->
      if x.token == token, do: Map.merge(x, %{last_used: System.system_time(:second)}), else: x
    end)

    {:noreply, [%{id: List.first(stats).id, token_info: token_info }] }
  end

  @impl true
  def handle_info(:schedule_delete_token, state) do
    Logger.info("Delete expired token request was sent")
    new_token = get_token_info(state)
    |> Enum.reject(fn x -> x.access_expires_in <= System.system_time(:second) end)

    new_state = Enum.map(state, fn item ->
      MnesiaToken.delete_expierd_token(item.id)

      if new_token == [] do
        MishkaUser.Acl.AclManagement.stop(item.id)
        MishkaContent.Cache.BookmarkManagement.stop(item.id)
      end

      Map.merge(
        item,
        %{
          id: item.id,
          token_info: new_token
        }
      )
    end)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:schedule_saving, stats) do
    Logger.info("Request was sent to save Tokens on Disk")
    # schedule_saving_token_on_disk(pid)
    {:noreply, stats}
  end

  @spec schedule_delete_token(atom | pid) :: reference
  def schedule_delete_token(pid) do
    Process.send_after(pid, :schedule_delete_token, @refresh_interval)
  end

  @spec schedule_saving_token_on_disk(atom | pid) :: reference
  def schedule_saving_token_on_disk(pid) do
    Process.send_after(pid, :schedule_saving, @saving_interval)
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
    # send error to log server
  end


  @spec count_refresh_token(id()) ::
          {:error, :count_refresh_token} | {:ok, :count_refresh_token}

  def count_refresh_token(user_id) do
    devices = user_id
    |> get_all()
    |> get_token_info()
    |> Enum.reject(fn x -> x.type == "access" end)
    |> Enum.count()

    if devices <= 5, do: {:ok, :count_refresh_token}, else: {:error, :count_refresh_token}
  end


  @spec get_token_info([any]) :: any
  def get_token_info(state) do
    case state do
      [] -> []
      items -> List.first(items).token_info
    end
  end

  defp get_token_with_rel(refresh_token, state) do
    get_token_info(state)
    |> Enum.find(fn x -> x.token == refresh_token end)
    |> case do
      nil ->
        state

      token_map ->
        new_token = get_token_info(state)
        |> Enum.reject(fn x -> x.rel == token_map.token_id end)

        Enum.map(state, fn item ->
          Map.merge(
            item,
            %{
              id: item.id,
              token_info: new_token
            }
          )
        end)
    end
  end


  defp create_new_state_to_get_disc_token(data, user_id) do
    %{
      id: user_id,
      token_info: Enum.map(data, fn [token_id, _user_id, token, exp_time, create_time, os] ->
        %{
          token_id: token_id,
          type: "refresh",
          token: token,
          os: os,
          create_time: create_time,
          last_used: create_time,
          access_expires_in: exp_time,
          rel: nil
        }
      end)
    }
  end


  defp via(key, value) do
    {:via, Registry, {MishkaUser.Token.TokenRegistry, key, value}}
  end
end
