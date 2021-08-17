defmodule MishkaContent.Blog.Category do

  alias MishkaDatabase.Schema.MishkaContent.Blog.Category

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Category,
          error_atom: :category,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_category")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:category)
  end

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:category)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:category)
  end

  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:category)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:category)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def show_by_alias_link(alias_link) do
    crud_get_by_field("alias_link", alias_link)
  end


  def search_category_title(title, limit) do
    like = "%#{title}%"
    try do
      from(cat in Category,
      where: like(cat.title, ^like),
      order_by: [desc: cat.inserted_at, desc: cat.id],
      limit: ^limit,
      select: %{
        id: cat.id,
        title: cat.title,
        inserted_at: cat.inserted_at,
        short_description: cat.short_description,
      })
      |> MishkaDatabase.Repo.all()
    rescue
      _e -> []
    end
  end

  def categories(filters: filters) do
    try do
      query = from(cat in Category, left_join: post in assoc(cat, :blog_posts)) |> convert_filters_to_where(filters)
      from([cat, post] in query,
      group_by: [cat.id, post.category_id],
      select: %{
        category_id: cat.id,
        category_title: cat.title,
        category_status: cat.status,
        category_alias_link: cat.alias_link,
        category_short_description: cat.short_description,
        category_main_image: cat.main_image,
        category_visibility: cat.category_visibility,
        category_updated_at: cat.updated_at,
        category_inserted_at: cat.inserted_at,
        post_count: count(post.id)
      })
      |> MishkaDatabase.Repo.all()
    rescue
      _e -> []
    end
  end

  def categories(conditions: {page, page_size}, filters: filters) do
    try do
      query = from(cat in Category) |> convert_filters_to_where(filters)
      from([cat] in query,
      order_by: [desc: cat.inserted_at, desc: cat.id],
      select: %{
        id: cat.id,
        title: cat.title,
        status: cat.status,
        alias_link: cat.alias_link,
        short_description: cat.short_description,
        main_image: cat.main_image,
        header_image: cat.header_image,
        category_visibility: cat.category_visibility,
        updated_at: cat.updated_at,
        inserted_at: cat.inserted_at,
      })
      |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
    rescue
      Ecto.Query.CastError ->
        %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
    end
  end

  def posts(conditions: {type, page, page_size}, filters: filters) when type in [:extra_data, :basic_data] do
    query = from(cat in Category) |> convert_filters_to_where(filters)
    from([cat] in query, join: post in assoc(cat, :blog_posts))
    |> fields(type)
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :title ->
          like = "%#{value}%"
          from cat in query, where: like(cat.title, ^like)
        _ -> from cat in query, where: field(cat, ^key) == ^value
      end
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

  def notify_subscribers({:ok, _, :category, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_category", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
