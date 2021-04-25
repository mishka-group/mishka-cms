defmodule MishkaContent.Blog.Post do
  # import Ecto.Query
  alias MishkaDatabase.Schema.MishkaContent.Blog.Post

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Post,
          error_atom: :post,
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

  def show_by_alias_link(alias_link) do
    crud_get_by_field("alias_link", alias_link)
  end

  def posts_with_priority(condition: {priority, page, page_size, status}) do
    from(post in Post,
    where: post.priority == ^priority,
    where: post.status == ^status,
    join: cat in assoc(post, :blog_categories),
    where: cat.status == ^status)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def posts_with_priority(condition: {priority, page, page_size}) do
    from(post in Post,
    where: post.priority == ^priority,
    join: cat in assoc(post, :blog_categories))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def posts(condition: {page, page_size, nil}) do
    from(post in Post, join: cat in assoc(post, :blog_categories))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def posts(condition: {page, page_size, status}) do
    from(post in Post,
    where: post.status == ^status,
    join: cat in assoc(post, :blog_categories),
    where: cat.status == ^status)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp fields(query) do
    from [post, cat] in query,
    select: %{
      category_id: cat.id,
      category_title: cat.title,
      category_status: cat.status,
      category_alias_link: cat.alias_link,
      category_short_description: cat.short_description,
      category_main_image: cat.main_image,

      post_id: post.title,
      post_short_description: post.short_description,
      post_main_image: post.main_image,
      post_status: post.status,
      post_alias_link: post.alias_link,
      post_priority: post.priority
    }
  end
end
