defmodule MishkaContent.General.CommentLike do

  alias MishkaDatabase.Schema.MishkaContent.CommentLike


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: CommentLike,
          error_atom: :comment_like,
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

  def delete(user_id, comment_id) do
    from(like in CommentLike, where: like.user_id == ^user_id and like.comment_id == ^comment_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :comment_like, :not_found}
      comment -> delete(comment.id)
    end
  rescue
    Ecto.Query.CastError -> {:error, :delete, :comment_like, :not_found}
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  # subquery
  def likes() do
    from(like in CommentLike,
    group_by: like.comment_id,
    select: %{count: count(like.id), comment_id: like.comment_id})
  end

  def allowed_fields(:atom), do: CommentLike.__schema__(:fields)
  def allowed_fields(:string), do: CommentLike.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
