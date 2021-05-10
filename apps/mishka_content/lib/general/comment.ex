defmodule MishkaContent.General.Comment do
  alias MishkaDatabase.Schema.MishkaContent.Comment
  alias MishkaContent.General.CommentLike

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Comment,
          error_atom: :comment,
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

  def delete(id) do
    crud_delete(id)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def show_by_user_id(user_id) do
    crud_get_by_field("user_id", user_id)
  end

  def comments(conditions: {page, page_size}, filters: filters) do
    from(com in Comment) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from bk in query, where: field(bk, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [com] in query,
    join: user in assoc(com, :users),
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

      user_id: user.id,
      user_full_name: user.full_name,
      user_username: user.username,
      like: like
    }
  end
end
