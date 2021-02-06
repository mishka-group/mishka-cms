defmodule MishkaUser.Token.TokenManagemnt do
  use GenServer

  # use GenServer, restart: :transient, shutdown: 10_000
  # we need to save %{user_id, tokens: [{token, os, create_time, last_used, exp time, type}]}


  @refresh_interval :timer.seconds(5) # :timer.seconds(5)
  @saving_interval :timer.seconds(300) # :timer.seconds(5)
  require Logger

  def start(default, user_id) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: converted_id(user_id))
  end

  def save(element, user_id) do
    # adds the record we want
    GenServer.cast(converted_id(user_id), {:push, element})
  end

  def get_all(user_id) do
    GenServer.call(converted_id(user_id), :pop)
  end

  def delete(user_id) do
    # create a difrent node to delete all the token on disk
    GenServer.call(converted_id(user_id), :delete)
  end

  def stop(user_id) do
    GenServer.cast(converted_id(user_id), :stop)
  end

  def delete_token(user_id, token) do
    GenServer.call(converted_id(user_id), {:delete, token})
  end

  def get_token(user_id, token) do
    GenServer.call(converted_id(user_id), {:get_token, token})
  end

  # Callbacks

  @impl true
  def init(stack) do
    Logger.info("Token OTP server was started")
    # change schedule_refresh to the thing we need to handel on other prosess
    schedule_refresh()
    # save token on disk evry 5 seconds or the second user configs
    schedule_saving_token_on_disk()
    {:ok, stack}
  end


  @impl true
  def handle_call({:get_token, token}, _from, state) do
    # it just changes the token_info
    token_map = get_token_info(state)
    |> Enum.find(fn x -> x.token == token end)

    {:reply, token_map, state}
  end


  @impl true
  def handle_call(:pop, _from, state) do
    {:reply, state, state}
  end


  @impl true
  def handle_call({:delete, token}, from, state) do
    # it just changes the token_info
    IO.inspect(from)
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
  def handle_cast({:push, element}, state) do
    case Enum.find(state, fn x -> x.id == element.id end) do
      nil ->
        update_state(nil, element, state)
      _ ->
        # create a task to delete expired token
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
  def handle_info(:schedule_refresh, stats) do
    schedule_refresh()
    {:noreply, stats}
  end

  @impl true
  def handle_info(:schedule_saving, stats) do
    Logger.info("Request was sent to save Tokens on Disk")
    schedule_saving_token_on_disk()
    {:noreply, stats}
  end

  def schedule_refresh() do
    Process.send_after(self(), :schedule_refresh, @refresh_interval)
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
end
