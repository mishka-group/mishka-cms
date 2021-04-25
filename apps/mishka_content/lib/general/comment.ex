defmodule MishkaContent.Comments do
  alias MishkaDatabase.Schema.MishkaContent.Comment
  alias MishkaContent.CommentLike

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Comment,
          error_atom: :comment,
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

  def show_by_user_id(user_id) do
    crud_get_by_field("user_id", user_id)
  end

  def comments(section_id, condition: %{priority: priority, paginate: {page, page_size}, status: status}) do
    from(com in Comment,
    where: com.section_id == ^section_id and com.priority == ^priority,
    where: com.status == ^status,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(section_id, condition: %{priority: priority, paginate: {page, page_size}}) do
    from(com in Comment,
    where: com.section_id == ^section_id and com.priority == ^priority,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(section_id, condition: %{section: section, priority: priority, paginate: {page, page_size}, status: status}) do
    from(com in Comment,
    where: com.section_id == ^section_id,
    where: com.section == ^section,
    where: com.priority == ^priority,
    where: com.status == ^status,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(section_id, condition: %{section: section, paginate: {page, page_size}, status: status}) do
    from(com in Comment,
    where: com.section_id == ^section_id,
    where: com.section == ^section,
    where: com.status == ^status,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(section_id, condition: %{section: section, paginate: {page, page_size}}) do
    from(com in Comment,
    where: com.section_id == ^section_id,
    where: com.section == ^section,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(section_id, condition: %{section: section, priority: priority, paginate: {page, page_size}}) do
    from(com in Comment,
    where: com.section_id == ^section_id,
    where: com.section == ^section,
    where: com.priority == ^priority,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(condition: %{priority: priority, paginate: {page, page_size}, status: status}) do
    from(com in Comment,
    where: com.priority == ^priority,
    where: com.status == ^status,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(condition: %{priority: priority, paginate: {page, page_size}}) do
    from(com in Comment,
    where: com.priority == ^priority,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(condition: %{status: status, paginate: {page, page_size}}) do
    from(com in Comment,
    where: com.status == ^status,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def comments(condition: %{paginate: {page, page_size}}) do
    from(com in Comment,
    join: user in assoc(com, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
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

      user_id: user.id,
      user_full_name: user.full_name,
      user_username: user.username,
      like: like
    }
  end
end
