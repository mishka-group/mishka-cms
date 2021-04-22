defmodule MishkaContent.Blog.Category do

  alias MishkaDatabase.Schema.MishkaContent.Blog.Category

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Category,
          error_atom: :category,
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


  def categories(status) do
    query = from cat in Category,
    where: cat.status == ^status,
    select: %{
      category_id: cat.id,
      category_title: cat.title,
      category_status: cat.status,
      category_alias_link: cat.alias_link,
      category_short_description: cat.short_description,
      category_main_image: cat.main_image,
    }

    MishkaDatabase.Repo.all(query)
  end

  def categories() do
    query = from cat in Category,
      select: %{
      category_id: cat.id,
      category_title: cat.title,
      category_status: cat.status,
      category_alias_link: cat.alias_link,
      category_short_description: cat.short_description,
      category_main_image: cat.main_image,
    }

    MishkaDatabase.Repo.all(query)
  end

  # we should remove repeated block code
  def posts(:basic_data, id, _page_number, _count, status) do
    query = from cat in Category,
      where: cat.id == ^id,
      where: cat.status == ^status,
      join: post in assoc(cat, :blog_posts),
      where: post.status == ^status,
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
      }

    # add paginate
    MishkaDatabase.Repo.all(query)
  end

  def posts(:extra_data, id, _page_number, _count, status) do
    query = from cat in Category,
      where: cat.id == ^id,
      where: cat.status == ^status,
      join: post in assoc(cat, :blog_posts),
      where: post.status == ^status,
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
      }

    # add paginate
    MishkaDatabase.Repo.all(query)
  end

  def posts(:basic_data, id, _page_number, _count) do
    query = from cat in Category,
      where: cat.id == ^id,
      join: post in assoc(cat, :blog_posts),
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
      }

    # add paginate
    MishkaDatabase.Repo.all(query)
  end

  def posts(:extra_data, id, _page_number, _count) do
    query = from cat in Category,
      where: cat.id == ^id,
      join: post in assoc(cat, :blog_posts),
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
      }

    # add paginate
    MishkaDatabase.Repo.all(query)
  end

end
