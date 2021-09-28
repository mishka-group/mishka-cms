defmodule MishkaContent.General.CommentLike do

  alias MishkaDatabase.Schema.MishkaContent.CommentLike


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: CommentLike,
          error_atom: :comment_like,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :comment_like
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

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :delete, :comment_like | :forced_to_delete | :get_record_by_id | :uuid,
           :comment_like | :not_found | Ecto.Changeset.t()}
          | {:ok, :delete, :comment_like, %{optional(atom) => any}}
  def delete(user_id, comment_id) do
    from(like in CommentLike, where: like.user_id == ^user_id and like.comment_id == ^comment_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :comment_like, :not_found}
      comment -> delete(comment.id)
    end
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("comment_like", "delete", db_error)
      {:error, :delete, :comment_like, :not_found}
  end

  @spec show_by_user_and_comment_id(data_uuid(), data_uuid()) ::
          {:error, :show_by_user_and_comment_id, :cast_error | :not_found}
          | {:ok, :show_by_user_and_comment_id, any}
  def show_by_user_and_comment_id(user_id, comment_id) do
    from(like in CommentLike, where: like.user_id == ^user_id and like.comment_id == ^comment_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :show_by_user_and_comment_id, :not_found}
      liked_record -> {:ok, :show_by_user_and_comment_id, liked_record}
    end
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("comment_like", "read", db_error)
      {:error, :show_by_user_and_comment_id, :cast_error}
  end


  @spec user_liked :: Ecto.Query.t()
  def user_liked() do
    from(like in CommentLike,
    select: %{comment_id: like.comment_id, user_id: like.user_id})
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: CommentLike.__schema__(:fields)
  def allowed_fields(:string), do: CommentLike.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
