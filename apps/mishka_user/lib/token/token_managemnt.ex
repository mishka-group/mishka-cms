defmodule MishkaUser.Token.TokenManagemnt do
  use GenServer

  @refresh_interval :timer.seconds(1) # :timer.seconds(5)
  @saving_interval :timer.seconds(300) # :timer.seconds(5)
  require Logger


  # we need a event to delete expired token every action
  def start(user_id) do
    GenServer.start_link(__MODULE__, default(user_id), name: converted_id(user_id))
  end

  defp default(user_id) do
    [%{id: user_id, token_info: []}]
  end

  def save(element, user_id) do
    schedule_delete_token(user_id)
    GenServer.cast(converted_id(user_id), {:push, element})
  end

  def get_all(user_id) do
    schedule_delete_token(user_id)
    GenServer.call(converted_id(user_id), :pop)
  end

  def delete(user_id) do
    schedule_delete_token(user_id)
    GenServer.call(converted_id(user_id), :delete)
  end

  def stop(user_id) do
    schedule_delete_token(user_id)
    GenServer.cast(converted_id(user_id), :stop)
  end

  def delete_token(user_id, token) do
    schedule_delete_token(user_id)
    GenServer.call(converted_id(user_id), {:delete, token})
  end

  def delete_child_token(user_id, refresh_token) do
    schedule_delete_token(user_id)
    GenServer.call(converted_id(user_id), {:delete_child_token, refresh_token})
  end

  def get_token(user_id, token) do
    schedule_delete_token(user_id)
    GenServer.call(converted_id(user_id), {:get_token, token})
  end

  # Callbacks

  @impl true
  def init(stack) do
    Logger.info("Token OTP server was started")
    # create a handelinfo to delete token after expire time
    List.first(stack).id
    |> schedule_delete_token()
    # save token on disk evry 5 seconds or the second user configs
    schedule_saving_token_on_disk()
    {:ok, stack}
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
    # update and replace new state on Disk
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
    case Enum.find(state, fn x -> x.id == element.id end) do
      nil ->
        update_state(nil, element, state)
      _ ->
        update_state(element, state)
    end
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
  def handle_info(:schedule_delete_token, state) do
    Logger.info("Delete expired token request was sent")
    new_token = get_token_info(state)
    |> Enum.reject(fn x -> x.access_expires_in <= System.system_time(:second) end)

    new_state = Enum.map(state, fn item ->
      Map.merge(
        item,
        %{
          id: item.id,
          token_info: new_token
        }
      )
    end)

    # update state on disk on another node()
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:schedule_saving, stats) do
    Logger.info("Request was sent to save Tokens on Disk")
    schedule_saving_token_on_disk()
    {:noreply, stats}
  end

  def schedule_delete_token(user_id) do
    # all event
    pid = GenServer.whereis(converted_id(user_id))
    if pid != nil, do: Process.send_after(pid, :schedule_delete_token, @refresh_interval)
  end

  def schedule_saving_token_on_disk() do
    # save token on disk, it should be found which way is better and has no dependencies
    Process.send_after(self(), :schedule_saving, @saving_interval)
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
  end

  def update_state(nil, element, state) do
    {:noreply, [element | state]}
  end

  def update_state(element, state) do
    {
      :noreply,
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
    }
  end

  defp converted_id(user_id), do: String.to_atom(user_id)

  def count_refresh_token(user_id) do
    devices = user_id
    |> get_all()
    |> get_token_info()
    |> Enum.reject(fn x -> x.type == "access" end)
    |> Enum.count()

    if devices <= 5, do: {:ok, :count_refresh_token}, else: {:error, :count_refresh_token}
  end

  defp get_token_info(state) do
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

end
