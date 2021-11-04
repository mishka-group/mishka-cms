defmodule MishkaContent.General.Notif do
  alias MishkaDatabase.Schema.MishkaContent.Notif
  alias MishkaContent.General.UserNotifStatus
  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Notif,
          error_atom: :notif,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :notif
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "notif")
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:notif)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:notif)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:notif)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:notif)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:notif)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec notifs([{:conditions, {integer() | String.t(), integer() | String.t()} | {integer() | String.t(), integer() | String.t(), :client}} | {:filters, map()}, ...]) ::
          Scrivener.Page.t()
  def notifs(conditions: {page, page_size, :client}, filters: filters) do
    from(notif in Notif) |> convert_filters_to_where(filters)
    |> fields(:client, filters.user_id)
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  def notifs(conditions: {page, page_size}, filters: filters) do
    from(notif in Notif) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  def notif(id, user_id) do
    from(notif in Notif,
      where: notif.id == ^id,
      where: notif.user_id == ^user_id  or is_nil(notif.user_id),
      left_join: status in subquery(UserNotifStatus.user_read_or_skipped),
      on: status.user_id == ^user_id and status.notif_id == notif.id,
      select: %{
        id: notif.id,
        status: notif.status,
        section: notif.section,
        section_id: notif.section_id,
        title: notif.title,
        description: notif.description,
        expire_time: notif.expire_time,
        extra: notif.extra,
        user_id: notif.user_id,
        type: notif.type,
        target: notif.target,
        user_notif_status: status,
        inserted_at: notif.inserted_at,
        updated_at: notif.updated_at
      }
    )
    |> MishkaDatabase.Repo.one()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      nil
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      cond do
        is_list(value) ->
          from notif in query, where: field(notif, ^key) in ^value
        key == :title ->
            like = "%#{value}%"
            from(notif in query, where: like(notif.title, ^like))

        key == :user_id ->
            from notif in query, where: field(notif, ^key) == ^value  or is_nil(notif.user_id)

        true -> from notif in query, where: field(notif, ^key) == ^value
      end
    end)
  end

  defp fields(query, :client, user_id) do
    from [notif] in query,
    left_join: status in subquery(UserNotifStatus.user_read_or_skipped),
    on: status.user_id == ^user_id and status.notif_id == notif.id,
    order_by: [desc: notif.inserted_at, desc: notif.id],
    select: %{
      id: notif.id,
      status: notif.status,
      section: notif.section,
      section_id: notif.section_id,
      title: notif.title,
      description: notif.description,
      expire_time: notif.expire_time,
      extra: notif.extra,
      user_id: notif.user_id,
      type: notif.type,
      target: notif.target,
      user_notif_status: status,
      inserted_at: notif.inserted_at,
      updated_at: notif.updated_at
    }
  end

  defp fields(query) do
    from [notif] in query,
    left_join: user in assoc(notif, :users),
    order_by: [desc: notif.inserted_at, desc: notif.id],
    select: %{
      id: notif.id,
      status: notif.status,
      section: notif.section,
      section_id: notif.section_id,
      title: notif.title,
      description: notif.description,
      expire_time: notif.expire_time,
      extra: notif.extra,
      user_id: notif.user_id,
      type: notif.type,
      target: notif.target,
      inserted_at: notif.inserted_at,
      updated_at: notif.updated_at
    }
  end

  def count_un_read(user_id) do
    new_time = DateTime.utc_now()
    from(
      notif in Notif,
      where: notif.user_id == ^user_id or is_nil(notif.user_id),
      left_join: status in subquery(UserNotifStatus.user_read_or_skipped),
      on: status.user_id == ^user_id and status.notif_id == notif.id,
      where: is_nil(status.status_type),
      where: is_nil(notif.expire_time) or notif.expire_time >= ^new_time,
      select: count(notif.id)
    )
    |> MishkaDatabase.Repo.one()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      0
  end

  # Reference code: https://elixirforum.com/t/3766/6
  def send_notification(query, notif_info, :repo_stream) do
    stream = MishkaDatabase.Repo.stream(query)
    MishkaDatabase.Repo.transaction(fn() ->
      Enum.to_list(stream)
    end)
    |> case do
      {:ok, list} ->
        list
        |> Task.async_stream(&deliver(&1, notif_info), max_concurrency: 10)
        |> Stream.run

      error ->
        # TODO: Shoule be stored on Activity db
        IO.inspect(error)
    end
  end

  def send_notification(notif_info, user_id, :repo_task) do
    Task.Supervisor.async_nolink(__MODULE__, fn ->
      deliver(user_id, notif_info)
    end)
  end

  defp deliver(user_id, params) do
    create(%{
      user_id: user_id,
      section: Map.get(params, :section),
      type: Map.get(params, :type),
      target: Map.get(params, :target),
      section_id: Map.get(params, :section_id),
      title: Map.get(params, :title),
      description: Map.get(params, :description),
      expire_time: Map.get(params, :expire_time),
      extra: Map.get(params, :extra),
    })
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Notif.__schema__(:fields)
  def allowed_fields(:string), do: Notif.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :notif, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "notif", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
