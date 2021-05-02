defmodule MishkaContent.Blog.Tag  do
  alias MishkaDatabase.Schema.MishkaContent.BlogTag
  alias MishkaDatabase.Schema.MishkaContent.Blog.Post

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogTag,
          error_atom: :blog_tag,
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

  def post_tags(post_id) do
    query = from post in Post,
      where: post.id == ^post_id,
      join: mapper in assoc(post, :blog_tags_mappers),
      join: tag in assoc(mapper, :blog_tags),
      select: %{
        id: tag.id,
        title: tag.title,
        alias_link: tag.alias_link,
        meta_keywords: tag.meta_keywords,
        meta_description: tag.meta_description,
        custom_title: tag.custom_title,
        robots: tag.robots,
      }
    MishkaDatabase.Repo.all(query)
  end

  def tag_posts(id, condition: %{paginate: {page, page_size}}) do
    from(tag in BlogTag,
      where: tag.id == ^id,
      left_join: mapper in assoc(tag, :blog_tags_mappers),
      join: post in assoc(mapper, :blog_posts),
      join: cat in assoc(post, :blog_categories),
      select: %{
        id: tag.id,
        title: tag.title,
        alias_link: tag.alias_link,
        meta_keywords: tag.meta_keywords,
        meta_description: tag.meta_description,
        custom_title: tag.custom_title,
        robots: tag.robots,


        category_id: cat.id,
        category_title: cat.title,
        category_status: cat.status,
        category_alias_link: cat.alias_link,
        category_short_description: cat.short_description,
        category_main_image: cat.main_image,

        post_id: post.id,
        post_title: post.title,
        post_short_description: post.short_description,
        post_main_image: post.main_image,
        post_status: post.status,
        post_alias_link: post.alias_link,
        post_priority: post.priority,
    })
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end
end
