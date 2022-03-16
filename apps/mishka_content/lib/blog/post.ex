defmodule MishkaContent.Blog.Post do

  alias MishkaDatabase.Schema.MishkaContent.Blog.Post
  alias MishkaContent.Blog.Like, as: UserLiked

  import Ecto.Query
  use MishkaDeveloperTools.DB.CRUD,
          module: Post,
          error_atom: :post,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :post
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDeveloperTools.DB.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_post")
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:post)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:post)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:post)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:post)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:post)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec show_by_alias_link(String.t()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_alias_link(alias_link) do
    crud_get_by_field("alias_link", alias_link)
  end

  @spec posts([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()} | {:user_id, nil | data_uuid()}, ...]) ::
          Scrivener.Page.t()
  def posts(conditions: {page, page_size}, filters: filters, user_id: user_id) when is_binary(user_id) or is_nil(user_id) do
    user_id = if(!is_nil(user_id), do: user_id, else: Ecto.UUID.generate)

    from(
      post in Post,
      join: cat in assoc(post, :blog_categories),
      left_join: like in assoc(post, :blog_likes),
      left_join: liked_user in subquery(UserLiked.user_liked),
      on: liked_user.user_id == ^user_id and liked_user.post_id == post.id
    )
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("blog_post", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :category_title ->
          like = "%#{value}%"
          from([post, cat, like] in query, where: like(cat.title, ^like))

        :title ->
          like = "%#{value}%"
          from([post, cat, like] in query, where: like(post.title, ^like))

        _ -> from([post, cat, like] in query, where: field(post, ^key) == ^value)
      end
    end)
  end

  defp fields(query) do
    from [post, cat, like, liked_user] in query,
    order_by: [desc: post.inserted_at, desc: post.id],
    group_by: [post.id, cat.id, like.post_id, liked_user.post_id, liked_user.user_id],
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
      unpublish: post.unpublish,
      robots: post.robots,
      like_count: count(like.id),
      liked_user: liked_user
    }
  end

  @spec post(String.t(), String.t() | atom()) :: map() | nil
  def post(alias_link, status) do
    # when this project has many records as like, I think like counter should be seprated or create a
    # lazy query instead of this
    # Post comments were seperated because the comment module is going to be used whole the project not only post
    from(post in Post,
    where: post.alias_link == ^alias_link and post.status == ^status,
    join: cat in assoc(post, :blog_categories),
    where: cat.status == ^status,
    left_join: author in assoc(post, :blog_authors),
    left_join: like in assoc(post, :blog_likes),
    left_join: user in assoc(author, :users),
    left_join: tag_map in assoc(post, :blog_tags_mappers),
    left_join: tag in assoc(tag_map, :blog_tags),
    preload: [blog_categories: cat, blog_authors: {author, users: user}, blog_tags: tag],
    order_by: [desc: post.inserted_at, desc: post.id],
    select: map(post, [
        :id, :title, :short_description, :main_image, :header_image, :description, :status,
        :priority, :location, :unpublish, :alias_link, :meta_keywords,
        :meta_description, :custom_title, :robots, :post_visibility, :allow_commenting,
        :allow_liking, :allow_printing, :allow_reporting, :allow_social_sharing,
        :allow_bookmarking, :show_hits, :show_time, :show_authors, :show_category,
        :show_links, :show_location, :category_id, :inserted_at, :updated_at,

        blog_categories: [:id, :title, :short_description, :main_image, :header_image, :description, :status,
        :sub, :alias_link, :meta_keywords, :meta_description, :custom_title, :robots,
        :category_visibility, :allow_commenting, :allow_liking, :allow_printing,
        :allow_reporting, :allow_social_sharing, :allow_subscription,
        :allow_bookmarking, :allow_notif, :show_hits, :show_time, :show_authors,
        :show_category, :show_links, :show_location],

        blog_authors: [
          :id, :user_id, :post_id,
          users: [:id, :full_name, :username]
        ],

        blog_tags: [
          :id, :title, :alias_link, :custom_title
        ]
      ]
    ))
    |> MishkaDatabase.Repo.one()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("blog_post", "read", db_error)
      nil
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Post.__schema__(:fields)
  def allowed_fields(:string), do: Post.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :post, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_post", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
