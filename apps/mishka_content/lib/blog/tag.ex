defmodule MishkaContent.Blog.Tag do
  alias MishkaDatabase.Schema.MishkaContent.BlogTag
  alias MishkaDatabase.Schema.MishkaContent.Blog.Post

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogTag,
          error_atom: :blog_tag,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_tag")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:tag)
  end

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:tag)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:tag)
  end

  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:tag)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:tag)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def tags(conditions: {page, page_size}, filters: filters) do
    query = from(tag in BlogTag) |> convert_filters_to_where(filters)
    from([tag] in query,
    select: %{
      id: tag.id,
      title: tag.title,
      alias_link: tag.alias_link,
      meta_keywords: tag.meta_keywords,
      meta_description: tag.meta_description,
      custom_title: tag.custom_title,
      robots: tag.robots,
      updated_at: tag.updated_at,
      inserted_at: tag.inserted_at,
    })
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  def post_tags(post_id) do
    query = from post in Post,
      where: post.id == ^post_id,
      join: mapper in assoc(post, :blog_tags_mappers),
      join: tag in assoc(mapper, :blog_tags),
      order_by: [desc: post.inserted_at, desc: post.id],
      select: %{
        id: tag.id,
        title: tag.title,
        alias_link: tag.alias_link,
        meta_keywords: tag.meta_keywords,
        meta_description: tag.meta_description,
        custom_title: tag.custom_title,
        robots: tag.robots,
        tag_inserted_at: mapper.inserted_at,
      }
    MishkaDatabase.Repo.all(query)
  rescue
    Ecto.Query.CastError -> []
  end

  def tag_posts(conditions: {page, page_size}, filters: filters) do
    query = from(tag in BlogTag)
    from(tag in query,
    left_join: mapper in assoc(tag, :blog_tags_mappers),
    join: post in assoc(mapper, :blog_posts),
    join: cat in assoc(post, :blog_categories),
    order_by: [desc: tag.inserted_at, desc: tag.id])
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :status ->
          from([tag, mapper, post, cat] in query, where: field(post, ^key) == ^value and field(cat, ^key) == ^value)

        :post_status ->
          from([tag, mapper, post, cat] in query, where: field(post, :status) == ^value and field(cat, :status) == ^value)

        :title ->
          like = "%#{value}%"
          from([tag, mapper, post, cat] in query, where: like(tag.title, ^like))

        :custom_title ->
          like = "%#{value}%"
          from([tag, mapper, post, cat] in query, where: like(tag.custom_title, ^like))

        _ -> from([tag, mapper, post, cat] in query, where: field(tag, ^key) == ^value)
      end
    end)
  end

  def fields(query) do
    from [tag, mapper, post, cat] in query,
    order_by: [desc: tag.inserted_at, desc: tag.id],
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
    }
  end

  def notify_subscribers({:ok, _, :tag, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_tag", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params

  def allowed_fields(:atom), do: BlogTag.__schema__(:fields)
  def allowed_fields(:string), do: BlogTag.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
