defmodule MishkaUser.Acl.Role do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """
  alias MishkaDatabase.Schema.MishkaUser.Role
  import Ecto.Query

  use MishkaDatabase.CRUD,
          module: Role,
          error_atom: :role,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :role
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "role")
  end

  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:role)
  end

  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:role)
  end

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:role)
  end

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}
  def show_by_id(id) do
    crud_get_record(id)
    |> notify_subscribers(:role)
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
    Ecto.Query.CastError ->
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
    Ecto.Query.CastError -> []
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
