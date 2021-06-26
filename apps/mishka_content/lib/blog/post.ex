defmodule MishkaContent.Blog.Post do
  # import Ecto.Query
  alias MishkaDatabase.Schema.MishkaContent.Blog.Post

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Post,
          error_atom: :post,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_post")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:post)
  end

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:post)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:post)
  end

  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:post)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:post)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def show_by_alias_link(alias_link) do
    crud_get_by_field("alias_link", alias_link)
  end

  def posts(conditions: {page, page_size}, filters: filters) do
    query = from(post in Post) |> convert_filters_to_where(filters)
    from(post in query, join: cat in assoc(post, :blog_categories))
    |> fields()
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
          from link in query, where: like(link.title, ^like)
        _ -> from link in query, where: field(link, ^key) == ^value
      end
    end)
  end

  defp fields(query) do
    from [post, cat] in query,
    order_by: [desc: post.inserted_at, desc: post.id],
    select: %{
      category_id: cat.id,
      category_title: cat.title,
      category_status: cat.status,
      category_alias_link: cat.alias_link,
      category_short_description: cat.short_description,
      category_main_image: cat.main_image,

      id: post.id,
      title: post.title,
      short_description: post.short_description,
      main_image: post.main_image,
      status: post.status,
      alias_link: post.alias_link,
      priority: post.priority,
      inserted_at: post.inserted_at,
      updated_at: post.updated_at,
      unpublish: post.unpublish
    }
  end

  def post(post_id, status) do
    # when this project has many records as like, I think like counter should be seprated or create a
    # lazy query instead of this
    # Post comments were seperated because the comment module is going to be used whole the project not only post
    from(post in Post,
    where: post.id == ^post_id and post.status == ^status,
    join: cat in assoc(post, :blog_categories),
    where: cat.status == ^status,
    order_by: [desc: post.inserted_at, desc: post.id],
    left_join: author in assoc(post, :blog_authors),
    left_join: like in assoc(post, :blog_likes),
    left_join: user in assoc(author, :users),
    preload: [blog_categories: cat, blog_likes: like, blog_authors: {author, users: user}],
    select: map(post, [
        :id, :title, :short_description, :main_image, :header_image, :description, :status,
        :priority, :location, :unpublish, :alias_link, :meta_keywords,
        :meta_description, :custom_title, :robots, :post_visibility, :allow_commenting,
        :allow_liking, :allow_printing, :allow_reporting, :allow_social_sharing,
        :allow_bookmarking, :show_hits, :show_time, :show_authors, :show_category,
        :show_links, :show_location, :category_id,

        blog_categories: [:id, :title, :short_description, :main_image, :header_image, :description, :status,
        :sub, :alias_link, :meta_keywords, :meta_description, :custom_title, :robots,
        :category_visibility, :allow_commenting, :allow_liking, :allow_printing,
        :allow_reporting, :allow_social_sharing, :allow_subscription,
        :allow_bookmarking, :allow_notif, :show_hits, :show_time, :show_authors,
        :show_category, :show_links, :show_location],

        blog_likes: [:id],

        blog_authors: [
          :id, :user_id, :post_id,
          users: [:id, :full_name, :username]
        ]
      ]
    ))
    |> MishkaDatabase.Repo.one()
  rescue
    Ecto.Query.CastError -> nil
  end

  def allowed_fields(:atom), do: Post.__schema__(:fields)
  def allowed_fields(:string), do: Post.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :post, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_post", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _) do
    IO.puts "this is a unformed"
    params
  end
end
