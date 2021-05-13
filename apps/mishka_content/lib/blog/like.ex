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

  def delete(user_id, post_id) do
    from(like in BlogLike, where: like.user_id == ^user_id and like.post_id == ^post_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :post_like, :not_found}
      liked_record -> delete(liked_record.id)
    end
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def likes() do
    from(like in BlogLike,
    group_by: like.post_id,
    select: %{count: count(like.id), post_id: like.post_id})
  end

  def allowed_fields(:atom), do: BlogLike.__schema__(:fields)
  def allowed_fields(:string), do: BlogLike.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
