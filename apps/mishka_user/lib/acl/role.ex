defmodule MishkaUser.Acl.Role do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """
  alias MishkaDatabase.Schema.MishkaUser.Role
  import Ecto.Query

  use MishkaDeveloperTools.DB.CRUD,
          module: Role,
          error_atom: :role,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :role
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDeveloperTools.DB.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "role")
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:role)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:role)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:role)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:role)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:role)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec show_by_display_name(String.t()) ::
  {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_display_name(name) do
    crud_get_by_field("name", name)
  end

  @spec roles([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def roles(conditions: {page, page_size}, filters: filters) do
    from(u in Role) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("role", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  @spec roles :: list()
  def roles() do
    from(role in Role,
      select: %{
        id: role.id,
        name: role.name,
        display_name: role.display_name,
      })
    |> MishkaDatabase.Repo.all()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("role", "read", db_error)
      []
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :name ->
          like = "%#{value}%"
          from [role] in query, where: like(role.name, ^like)

        :display_name ->
          like = "%#{value}%"
          from [role] in query, where: like(role.display_name, ^like)

        _ -> from [role] in query, where: field(role, ^key) == ^value
      end
    end)
  end

  defp fields(query) do
    from [role] in query,
    order_by: [desc: role.inserted_at, desc: role.id],
    select: %{
      id: role.id,
      name: role.name,
      display_name: role.display_name,
      inserted_at: role.inserted_at
    }
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Role.__schema__(:fields)
  def allowed_fields(:string), do: Role.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :role, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "role", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
