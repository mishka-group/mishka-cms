defmodule MishkaContent.Blog.Like do
  alias MishkaDatabase.Schema.MishkaContent.BlogLike


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogLike,
          error_atom: :post_like,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_like")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:like)
  end

  def edit(attrs) do
    crud_edit(attrs)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:like)
  end

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

  def show_by_id(id) do
    crud_get_record(id)
  end

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

  def likes() do
    from(like in BlogLike,
    group_by: like.post_id,
    select: %{count: count(like.id), post_id: like.post_id})
  end

  def user_liked() do
    from(like in BlogLike,
    select: %{post_id: like.post_id, user_id: like.user_id})
  end

  def notify_subscribers({:ok, _, :post_like, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_like", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _) do
    IO.puts "this is a unformed"
    params
  end

  def allowed_fields(:atom), do: BlogLike.__schema__(:fields)
  def allowed_fields(:string), do: BlogLike.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
