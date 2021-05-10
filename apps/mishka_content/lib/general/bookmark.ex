defmodule MishkaContent.General.Bookmark do
  alias MishkaDatabase.Schema.MishkaContent.Bookmark

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Bookmark,
          error_atom: :bookmark,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def create(attrs) do
    crud_add(attrs)
  end

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  def edit(attrs) do
    crud_edit(attrs)
  end

  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  def delete(id) do
    crud_delete(id)
  end

  def delete(user_id, section_id) do
    [user_id, section_id]
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def bookmarks(conditions: {page, page_size}, filters: filters) do
    from(bk in Bookmark) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from bk in query, where: field(bk, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [bk] in query,
    join: user in assoc(bk, :users),
    order_by: [desc: bk.inserted_at, desc: bk.id],
    select: %{
      id: bk.id,
      status: bk.status,
      section: bk.section,
      section_id: bk.section_id,
      extra: bk.extra,
    }
  end
end
