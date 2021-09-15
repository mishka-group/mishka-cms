defmodule MishkaContent.Cache.ContentDraftManagement do
  use GenServer, restart: :temporary
  require Logger
  alias MishkaContent.Cache.ContentDraftDynamicSupervisor

  @type params() :: map()
  @type id() :: String.t()
  @type token() :: String.t()

  def start_link(args) do
    id = Keyword.get(args, :id) || Ecto.UUID.generate
    section_id = Keyword.get(args, :section_id) || :public
    dynamic_form = Keyword.get(args, :dynamic_form) || []

    section = Keyword.get(args, :section)
    user_id = Keyword.get(args, :user_id)

    GenServer.start_link(__MODULE__, default(id, section, user_id, section_id, dynamic_form), name: via(id, section))
  end

  defp default(id, section, user_id, section_id, dynamic_form) do
    %{id: id, section: section, dynamic_form: dynamic_form, user_id: user_id, section_id: section_id}
  end


  def save(user_id, section, section_id, dynamic_form \\ []) do
    ContentDraftDynamicSupervisor.start_job([user_id: user_id, section: section, section_id: section_id, dynamic_form: dynamic_form])
  end

  def get_draft_by_id(id: id) do
    case ContentDraftDynamicSupervisor.get_draft_pid(id) do
      {:ok, :get_draft_pid, pid} -> GenServer.call(pid, :pop)
      {:error, :get_draft_pid} -> {:error, :get_draft_by_id, :not_found}
    end
  end

  def get_records_ids(section: section, user_id: user_id) do
    ContentDraftDynamicSupervisor.running_imports(section: section)
    |> Enum.map(fn item -> GenServer.call(item.pid, :pop) end)
    |> Enum.map(fn item -> if item.user_id == user_id, do: item.id end)
    |> Enum.reject(fn x -> is_nil(x) end)
  end

  def get_records_ids(section: section) do
    ContentDraftDynamicSupervisor.running_imports(section: section)
    |> Enum.map(fn item -> item.id end)
  end

  def get_record_id(section: section, section_id: section_id) do
    ContentDraftDynamicSupervisor.running_imports(section: section)
    |> Enum.map(fn item -> GenServer.call(item.pid, :pop) end)
    |> Enum.map(fn item -> if item.section_id == section_id, do: item.id end)
    |> Enum.reject(fn x -> is_nil(x) end)
  end

  def update_record(id: id, dynamic_form: dynamic_form) do
    case ContentDraftDynamicSupervisor.get_draft_pid(id) do
      {:error, :get_draft_pid} -> {:error, :update_record, :not_found}
      {:ok, :get_draft_pid, pid} -> GenServer.cast(pid, {:push, dynamic_form})
    end
  end

  def delete_record(id: id) do
    case ContentDraftDynamicSupervisor.get_draft_pid(id) do
      {:error, :get_draft_pid} -> {:error, :delete_record, :not_found}
      {:ok, :get_draft_pid, pid} -> GenServer.cast(pid, :stop)
    end
  end

  def delete_records(section: section, user_id: user_id) do
    get_records_ids(section: section, user_id: user_id)
    |> Enum.map(fn item ->
      GenServer.cast(item, :stop)
    end)
  end

  def delete_records(section: section, section_id: section_id) do
    get_record_id(section: section, section_id: section_id)
    |> Enum.map(fn item ->
      GenServer.cast(item, :stop)
    end)
  end

  def delete_records(section: section) do
    get_records_ids(section: section)
    |> Enum.map(fn item ->
      GenServer.cast(item.pid, :stop)
    end)
  end


  # Callbacks

  @impl true
  def init(state) do
    Logger.info("OTP Content Draft server was started")
    {:ok, state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, dynamic_form}, state) do
    {:noreply, default(state.id, state.section, state.user_id, state.section_id, dynamic_form)}
  end

  @impl true
  def handle_cast(:stop, state) do
    Logger.info("OTP Content Draft server was stoped and clean State, state_id: #{state.id}")
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast({:delete, section_id}, state) do
    new_state = Enum.reject(state.user_bookmarks, fn bk -> bk.section_id == section_id  end)
    {:noreply, %{id: state.id, user_bookmarks: new_state}}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Reason of Terminate #{inspect(reason)}")
  end

  defp via(id, section) do
    {:via, Registry, {MishkaContent.Cache.ContentDraftRegistry, id, section}}
  end
end
