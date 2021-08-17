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

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "role")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:role)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:role)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:role)
  end

  def show_by_id(id) do
    crud_get_record(id)
    |> notify_subscribers(:role)
  end

  def show_by_display_name(name) do
    crud_get_by_field("name", name)
  end

  def roles(conditions: {page, page_size}, filters: filters) do
    from(u in Role) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

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

  def allowed_fields(:atom), do: Role.__schema__(:fields)
  def allowed_fields(:string), do: Role.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :role, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "role", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
