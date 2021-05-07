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

  def edit(attrs) do
    crud_edit(attrs)
  end

  def delete(id) do
    crud_delete(id)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  # it should be asked how can we create  multi params of advanced search
  def bookmarks(user_id, condition: %{paginate: {page, page_size}}) do
    from(bk in Bookmark,
    where: bk.user_id == ^user_id,
    join: user in assoc(bk, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def bookmarks(condition: %{paginate: {page, page_size}}) do
    from(bk in Bookmark,
    join: user in assoc(bk, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp fields(query) do
    from [bk, user] in query,
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
