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

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  def edit(attrs) do
    crud_edit(attrs)
  end

  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
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

  def categories(filters: filters) do
    try do
      query = from(cat in Category) |> convert_filters_to_where(filters)
      from([cat] in query,
      select: %{
        category_id: cat.id,
        category_title: cat.title,
        category_status: cat.status,
        category_alias_link: cat.alias_link,
        category_short_description: cat.short_description,
        category_main_image: cat.main_image,
      })
      |> MishkaDatabase.Repo.all()
    rescue
      _e -> []
    end
  end

  def posts(conditions: {type, page, page_size}, filters: filters) when type in [:extra_data, :basic_data] do
    query = from(cat in Category) |> convert_filters_to_where(filters)
    from([cat] in query, join: post in assoc(cat, :blog_posts))
    |> fields(type)
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from cat in query, where: field(cat, ^key) == ^value
    end)
  end

  defp fields(query, :basic_data) do
    from [cat, post] in query,
    order_by: [desc: post.inserted_at, desc: post.id],
    select: %{
      category: map(cat,
        [
          :id, :title, :short_description, :main_image, :status, :alias_link
        ]),
      post: map(post,
        [
          :id, :title, :short_description, :main_image, :status, :alias_link
        ])
    }
  end

  defp fields(query, :extra_data) do
    from [cat, post] in query,
    order_by: [desc: post.inserted_at, desc: post.id],
    select: %{
      category: map(cat,
        [
          :id, :title, :short_description, :main_image, :header_image, :description, :status,
          :sub, :alias_link, :meta_keywords, :meta_description, :custom_title, :robots,
          :category_visibility, :allow_commenting, :allow_liking, :allow_printing,
          :allow_reporting, :allow_social_sharing, :allow_subscription,
          :allow_bookmarking, :allow_notif, :show_hits, :show_time, :show_authors,
          :show_category, :show_links, :show_location
        ]),
      post: map(post,
        [
          :id, :title, :short_description, :main_image, :header_image, :description, :status,
          :priority, :location, :unpublish, :alias_link, :meta_keywords,
          :meta_description, :custom_title, :robots, :post_visibility, :allow_commenting,
          :allow_liking, :allow_printing, :allow_reporting, :allow_social_sharing,
          :allow_bookmarking, :show_hits, :show_time, :show_authors, :show_category,
          :show_links, :show_location, :category_id
        ])
    }
  end

  def allowed_fields(:atom), do: Category.__schema__(:fields)
  def allowed_fields(:string), do: Category.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
