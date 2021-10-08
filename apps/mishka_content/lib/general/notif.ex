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

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
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
      MishkaContent.db_content_activity_error("notif", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from notif in query, where: field(notif, ^key) == ^value
    end)
  end

  defp fields(query, :client) do
    from [notif] in query,
    left_join: user in assoc(notif, :users),
    left_join: status in assoc(notif, :user_notif_statuses),
    or_where: is_nil(notif.user_id),
    order_by: [desc: notif.inserted_at, desc: notif.id],
    select: %{
      id: notif.id,
      status: notif.status,
      section: notif.section,
      section_id: notif.section_id,
      short_description: notif.short_description,
      expire_time: notif.expire_time,
      extra: notif.extra,
      user_id: notif.user_id,
      type: notif.type,
      target: notif.target,
      status_type: status.type
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
      short_description: notif.short_description,
      expire_time: notif.expire_time,
      extra: notif.extra,
      user_id: notif.user_id,
      type: notif.type,
      target: notif.target,
    }
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Notif.__schema__(:fields)
  def allowed_fields(:string), do: Notif.__schema__(:fields) |> Enum.map(&Atom.to_string/1)


  # TODO: Create a link creator for navigating to page concerned
  # TODO: top list should create a link when user clicks on a notification
  # TODO: Create user_notif_statuses migration {user_id, notif_id, inserted_at, status_type}
end
