defmodule MishkaContent.Blog.Like do
  alias MishkaDatabase.Schema.MishkaContent.BlogLike


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogLike,
          error_atom: :post_like,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :post_like
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_like")
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:like)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:like)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:like)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:like)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:like)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :delete,
           :category | :forced_to_delete | :get_record_by_id | :post_like | :uuid,
           :category | :not_found | Ecto.Changeset.t()}
          | {:ok, :delete, :category, %{optional(atom) => any}}
  def delete(user_id, post_id) do
    from(like in BlogLike, where: like.user_id == ^user_id and like.post_id == ^post_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :post_like, :not_found}
      liked_record -> delete(liked_record.id)
    end
  rescue
    Ecto.Query.CastError -> {:error, :delete, :post_like, :not_found}
  end

  @spec show_by_user_and_post_id(data_uuid(), data_uuid()) ::
          {:error, :show_by_user_and_post_id, :cast_error | :not_found}
          | {:ok, :show_by_user_and_post_id, any}
  def show_by_user_and_post_id(user_id, post_id) do
    from(like in BlogLike, where: like.user_id == ^user_id and like.post_id == ^post_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :show_by_user_and_post_id, :not_found}
      liked_record -> {:ok, :show_by_user_and_post_id, liked_record}
    end
  rescue
    Ecto.Query.CastError -> {:error, :show_by_user_and_post_id, :cast_error}
  end

  @spec count_post_likes(data_uuid(), data_uuid()) :: map()
  def count_post_likes(post_id, user_id) do
    user_id = if(!is_nil(user_id), do: user_id, else: Ecto.UUID.generate)

    from(like in BlogLike,
    where: like.post_id == ^post_id,
    left_join: liked_user in subquery(user_liked()),
    on: liked_user.user_id == ^user_id and liked_user.post_id == ^post_id,
    group_by: [like.post_id, liked_user.post_id, liked_user.user_id],
    select: %{count: count(like.id), liked_user: liked_user})
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> %{count: 0, liked_user: %{post_id: nil, user_id: nil}}
      record -> record
    end
  end

  @spec likes :: Ecto.Query.t()
  def likes() do
    from(like in BlogLike,
    group_by: like.post_id,
    select: %{count: count(like.id), post_id: like.post_id})
  end

  @spec user_liked :: Ecto.Query.t()
  def user_liked() do
    from(like in BlogLike,
    select: %{post_id: like.post_id, user_id: like.user_id})
  end

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :post_like, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_like", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params


  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: BlogLike.__schema__(:fields)
  def allowed_fields(:string), do: BlogLike.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
