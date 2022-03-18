defmodule MishkaContent.General.Activity do

  alias MishkaDatabase.Schema.MishkaContent.Activity

  import Ecto.Query
  use MishkaDeveloperTools.DB.CRUD,
          module: Activity,
          error_atom: :activity,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :activity
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDeveloperTools.DB.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "activity")
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:activity)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec activities([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def activities(conditions: {page, page_size}, filters: filters) do
    from(activity in Activity) |> convert_filters_to_where(filters)
    |> field()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("activity", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from [activity] in query, where: field(activity, ^key) == ^value
    end)
  end

  defp field(query) do
    from [activity] in query,
    order_by: [desc: activity.inserted_at, desc: activity.id],
    select: %{
      id: activity.id,
      type: activity.type,
      section: activity.section,
      section_id: activity.section_id,
      priority: activity.priority,
      status: activity.status,
      action: activity.action,
      extra: activity.extra,
      updated_at: activity.updated_at,
      inserted_at: activity.inserted_at
    }
  end

  @spec create_activity_by_start_child(map(), map()) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def create_activity_by_start_child(params, extra \\ %{}) do
    Task.Supervisor.start_child(MishkaContent.General.ActivityTaskSupervisor, fn ->
      convert_task_to_db(params, extra)
    end)
  end

  @spec create_activity_by_task(map(), map()) :: Task.t()
  def create_activity_by_task(params, extra \\ %{}) do
    Task.Supervisor.async_nolink(MishkaContent.General.ActivityTaskSupervisor, fn ->
      convert_task_to_db(params, extra)
    end)
  end

  defp convert_task_to_db(params, extra) do
    create(
        %{
          type: params.type,
          section: params.section,
          section_id: params.section_id,
          priority: params.priority,
          status: params.status,
          action: params.action,
          extra: extra
        }
      )
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Activity.__schema__(:fields)
  def allowed_fields(:string), do: Activity.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :activity, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "activity", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params

  def router_catch(conn, kind, reason) do
    create_activity_by_task(%{
      type: "html_router",
      section: "other",
      section_id: nil,
      action: "other",
      priority: create_activity_router_priority(Map.get(reason, :plug_status)),
      status: Atom.to_string(kind)
    }, %{
      user_id: Map.get(conn.assigns, :user_id),
      kind: kind,
      plug_status: Map.get(reason, :plug_status),
      params: Map.get(reason.conn, :params),
      path_info: Map.get(reason.conn, :path_info),
      path_params: Map.get(reason.conn, :path_params),
      message: Map.get(reason, :message),
      port: Map.get(reason.conn, :port),
      router: Map.get(reason, :router),
      cowboy_ip: to_string(:inet_parse.ntoa(conn.remote_ip))
    })
  end

  defp create_activity_router_priority(plug_status) do
    case plug_status do
      500 -> "high"
      401 -> "medium"
      404 -> "low"
      _ -> "medium"
    end
  end
end
