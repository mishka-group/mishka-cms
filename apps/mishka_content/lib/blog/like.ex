defmodule MishkaContent.Blog.Like do
  alias MishkaDatabase.Schema.MishkaContent.BlogLike


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogLike,
          error_atom: :post_like,
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

  def delete(_user_id, _post_id) do

  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def likes() do
    from(like in BlogLike,
    group_by: like.post_id,
    select: %{count: count(like.id), post_id: like.post_id})
  end
end
