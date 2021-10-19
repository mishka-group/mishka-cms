defmodule MishkaContent.General.Notif do
  alias MishkaDatabase.Schema.MishkaContent.Notif

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
    |> fields(:client)
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
      IO.inspect(db_error)
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
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

  defp fields(query, :client) do
    from [notif] in query,
    left_join: user in assoc(notif, :users),
    left_join: status in assoc(notif, :user_notif_statuses),
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
      status_type: status.type,
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

  # TODO: Create a link creator for navigating to page concerned
  # TODO: top list should create a link when user clicks on a notification

  def count_un_read(user_id) do
    from(
      notif in Notif,
      left_join: status in assoc(notif, :user_notif_statuses),
      where: notif.user_id == ^user_id or is_nil(notif.user_id),
      where: is_nil(status.type),
      select: count(notif.id)
    )
    |> MishkaDatabase.Repo.one()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      0
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
