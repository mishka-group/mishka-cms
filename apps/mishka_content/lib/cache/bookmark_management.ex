defmodule MishkaContent.Cache.BookmarkManagement do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaContent.Cache.BookmarkDynamicSupervisor
  alias MishkaContent.General.Bookmark

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

  def start_link(args) do
    id = Keyword.get(args, :id)
    type = Keyword.get(args, :type)

    GenServer.start_link(__MODULE__, default(id), name: via(id, type))
  end

  defp default(user_id) do
    %{id: user_id, user_bookmarks: Bookmark.user_all_bookmarks(user_id)}
  end

  @spec save(params(), id(), id) :: :ok
  def save(element, user_id, section_id) do
    with {:ok, :get_user_pid, pid} <- BookmarkDynamicSupervisor.get_user_pid(user_id) do
      GenServer.cast(pid, {:push, element, section_id})
    else
      {:error, :get_user_pid} ->
        BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
        save(element, user_id, section_id)
    end
  end

  @spec get_all(id()) :: any
  def get_all(user_id) do
    with {:ok, :get_user_pid, pid} <- BookmarkDynamicSupervisor.get_user_pid(user_id) do
      GenServer.call(pid, :pop)
    else
      {:error, :get_user_pid} ->
        BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
        get_all(user_id)
    end
  end

  @spec get_record(id(), id()) :: any
  def get_record(user_id, section_id) when not is_nil(user_id) do
    with {:ok, :get_user_pid, pid} <- BookmarkDynamicSupervisor.get_user_pid(user_id) do
      GenServer.call(pid, {:pop, section_id})
    else
      {:error, :get_user_pid} ->
        BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
        get_record(user_id, section_id)
    end
  end

  def get_record(_user_id, _section_id) do
    nil
  end

  @spec delete(id()) :: any
  def delete(user_id) do
    with {:ok, :get_user_pid, pid} <- BookmarkDynamicSupervisor.get_user_pid(user_id) do
      GenServer.cast(pid, :delete)
    else
      {:error, :get_user_pid} ->
        BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
        delete(user_id)
    end
  end

  @spec delete(id(), id()) :: any
  def delete(user_id, section_id) do
    with {:ok, :get_user_pid, pid} <- BookmarkDynamicSupervisor.get_user_pid(user_id) do
      GenServer.cast(pid, {:delete, section_id})
    else
      {:error, :get_user_pid} ->
        BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
        delete(user_id, section_id)
    end
  end

  @spec stop(id()) :: :ok
  def stop(user_id) do
    with {:ok, :get_user_pid, pid} <- BookmarkDynamicSupervisor.get_user_pid(user_id) do
      GenServer.cast(pid, :stop)
    else
      {:error, :get_user_pid} ->
        BookmarkDynamicSupervisor.start_job([id: user_id, type: "user_bookmarks"])
        stop(user_id)
    end
  end

  # Callbacks

  @impl true
  def init(state) do
    Logger.info("OTP User Bookmark server was started")
    {:ok, state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:pop, section_id}, _from, state) do
    filterd_sate = Enum.find(state.user_bookmarks, fn bk -> bk.section_id == section_id end)

    {:reply, filterd_sate, state}
  end

  @impl true
  def handle_cast({:push, element, section_id}, state) do
    new_bookmarks = Enum.reject(state.user_bookmarks, fn bk -> bk.section_id == section_id  end)
    {:noreply, %{id: state.id, user_bookmarks: [element | new_bookmarks]}}
  end

  @impl true
  def handle_cast(:delete, _state) do
    {:noreply, %{}}
  end

  @impl true
  def handle_cast({:delete, section_id}, state) do
    new_state = Enum.reject(state.user_bookmarks, fn bk -> bk.section_id == section_id  end)
    {:noreply, %{id: state.id, user_bookmarks: new_state}}
  end

  @impl true
  def handle_cast(:stop, stats) do
    Logger.info("OTP User Bookmark server was stoped and clean State")
    {:stop, :normal, stats}
  end


  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
  end

  defp via(key, value) do
    {:via, Registry, {MishkaContent.Cache.BookmarkRegistry, key, value}}
  end
end
