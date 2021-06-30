defmodule MishkaContent.General.Comment do
  alias MishkaDatabase.Schema.MishkaContent.Comment
  alias MishkaContent.General.CommentLike

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Comment,
          error_atom: :comment,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "comment")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:comment)
  end

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:comment)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:comment)
  end

  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:comment)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:comment)
  end

  def delete(user_id, id) do
    from(com in Comment, where: com.user_id == ^user_id and com.id == ^id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :edit, :comment, :not_found}
      comment -> edit(%{id: comment.id, status: :soft_delete})
    end
  rescue
    Ecto.Query.CastError -> {:error, :edit, :comment, :not_found}
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def show_by_user_id(user_id) do
    crud_get_by_field("user_id", user_id)
  end

  def comments(conditions: {page, page_size}, filters: filters) do
    from(com in Comment, join: user in assoc(com, :users)) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  def comment(filters: filters) do
    from(com in Comment, join: user in assoc(com, :users)) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.one()
  rescue
    Ecto.Query.CastError -> nil
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from com in query, where: field(com, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [com, user] in query,
    order_by: [desc: com.inserted_at, desc: com.id],
    left_join: like in subquery(CommentLike.likes()),
    on: com.id == like.comment_id,
    select: %{
      id: com.id,
      description: com.description,
      status: com.status,
      priority: com.priority,
      sub: com.sub,
      section: com.section,
      section_id: com.section_id,
      updated_at: com.updated_at,
      inserted_at: com.inserted_at,

      user_id: user.id,
      user_full_name: user.full_name,
      user_username: user.username,
      like: like
    }
  end

  def allowed_fields(:atom), do: Comment.__schema__(:fields)
  def allowed_fields(:string), do: Comment.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :comment, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "comment", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _) do
    IO.puts "this is a unformed"
    params
  end
end
