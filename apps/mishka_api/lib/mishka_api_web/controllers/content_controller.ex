defmodule MishkaApiWeb.ContentController do
  use MishkaApiWeb, :controller

  # add ip limitter and os info
  # handel cache of contents


  alias MishkaContent.Blog.{Category, Post, Like, Tag, TagMapper, BlogLink, Author}
  alias MishkaContent.General.{Comment, CommentLike, Bookmark, Notif, Subscription}

  # Activity module needs a good way to store data
  # all the Strong paramiters which is loaded here should be chacked and test ID in create
  # some queries need a extra delete with new paramaters

  @allowed_category_fields Category.allowed_fields(:string)

  def posts(conn, %{"page" => page, "filters" => %{"status" => status} = params})  when status in [:active, :archive] do
    # action blogs:view
    # list of categories
    filters = Map.take(params, @allowed_category_fields |> Enum.map(&String.to_existing_atom/1))

    Post.posts(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def posts(conn, %{"category_id" => _category_id, "page" => page, "filters" => params}) do
    # action blogs:edit
    # list of categories
    filters = Map.take(params, @allowed_category_fields |> Enum.map(&String.to_existing_atom/1))

    Post.posts(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.posts(conn)
  end
  def post(conn, %{"post_id" => post_id, "status" => status}) when status in [:active, :archive] do
    # action blogs:view
    # list of categories
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn)
  end

  def post(conn, %{"post_id" => post_id, "status" => status, "comment" => %{"page" => _page}}) when status in [:active, :archive] do
    # action blogs:view
    # list of categories
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn)
  end

  def post(conn, %{"post_id" => post_id, "status" => status, "comment" => %{"page" => _page}})do
    # action blogs:edit
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn)
  end

  def post(conn, %{"post_id" => post_id, "status" => status})do
    # action blogs:edit
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn)
  end

  def category(conn, %{"category_id" => id}) do
    Category.show_by_id(id)
    |> MishkaApi.ContentProtocol.category(conn, Category.allowed_fields(:atom))
  end

  def category(conn, %{"alias_link" => alias_link}) do
    Category.show_by_alias_link(alias_link)
    |> MishkaApi.ContentProtocol.category(conn, Category.allowed_fields(:atom))
  end

  def categories(conn, %{"filters" => params}) when is_map(params) do
    # action blogs:edit
    Category.categories(filters: MishkaDatabase.convert_string_map_to_atom_map(params))
    |> MishkaApi.ContentProtocol.categories(conn)
  end

  def categories(conn, _params) do
    # action blogs:view
    Category.categories(filters: %{status: :active})
    |> MishkaApi.ContentProtocol.categories(conn)
  end

  def create_post(conn, params) do
    # action blogs:edit
    # action blogs:create
    Post.create(params, @allowed_category_fields)
    |> MishkaApi.ContentProtocol.create_post(conn)
  end
  def create_category(conn, params) do
    # action blogs:edit
    Category.create(params, Category.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_category(conn, Category.allowed_fields(:atom))
  end
  def like_post(conn, %{"post_id" => post_id}) do
    # action blogs:view
    Like.create(%{user_id: Ecto.UUID.generate, post_id: post_id})
    |> MishkaApi.ContentProtocol.like_post(conn)
  end

  def delete_post_like(conn, %{"post_id" => post_id}) do
    # action blogs:user_id:view
    Like.delete(Ecto.UUID.generate, post_id)
    |> MishkaApi.ContentProtocol.delete_post_like(conn)
  end

  def edit_post(conn, %{"post_id" => post_id} = params) do
    # action blogs:edit
    Post.edit(Map.merge(params, %{"id" => post_id}), @allowed_category_fields)
    |> MishkaApi.ContentProtocol.edit_post(conn)
  end

  def delete_post(conn, %{"post_id" => post_id}) do
    # action blogs:edit
    # change flag of status
    Post.edit(%{id: post_id, status: :soft_delete})
    |> MishkaApi.ContentProtocol.delete_post(conn)
  end

  def destroy_post(conn, %{"post_id" => post_id}) do
    # action blogs:*
    Post.delete(post_id)
    |> MishkaApi.ContentProtocol.delete_post(conn)
  end

  def edit_category(conn, %{"category_id" => category_id} = params) do
    # action blogs:edit
    Category.edit(Map.merge(params, %{"id" => category_id}), Category.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_category(conn, Category.allowed_fields(:atom))
  end

  def delete_category(conn, %{"category_id" => category_id}) do
    # action blogs:edit
    # change flag of status
    Category.edit(%{id: category_id, status: :soft_delete})
    |> MishkaApi.ContentProtocol.delete_category(conn, Category.allowed_fields(:atom))
  end

  def destroy_category(conn, %{"category_id" => category_id}) do
    # action *
    Category.delete(category_id)
    |> MishkaApi.ContentProtocol.destroy_category(conn, Category.allowed_fields(:atom))
  end

  def comment(conn, %{"comment_id" => comment_id, "status" => status}) when status in [:active, :archive] do
    # action blogs:view
    Comment.comments(conditions: {1, 1}, filters: %{id: comment_id, status: status})
    |> MishkaApi.ContentProtocol.comment(conn)
  end

  def comment(conn, %{"comment_id" => comment_id, "filters" => filters}) do
    # action blogs:edit
    Comment.comments(conditions: {1, 1}, filters: Map.merge(%{"id" => comment_id}, filters))
    |> MishkaApi.ContentProtocol.comment(conn)
  end

  def comments(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in [:active, :archive] do
    # action blogs:edit
    Comment.comments(conditions: {page, 20}, filters: params)
    |> MishkaApi.ContentProtocol.comment(conn)
  end

  def comments(conn, %{"page" => page, "filters" => params}) do
    # action blogs:edit
    Comment.comments(conditions: {page, 20}, filters: params)
    |> MishkaApi.ContentProtocol.comment(conn)
  end

  def create_comment(conn, %{"section_id" => _section_id, "description" => _description} = params) do
    # action blogs:view
    Comment.create(Map.merge(params, %{"user_id" => Ecto.UUID.generate}), @allowed_category_fields)
    |> MishkaApi.ContentProtocol.create_comment(conn)
  end

  def like_comment(conn, %{"comment_id" => comment_id}) do
    # action *:view
    CommentLike.create(%{user_id: Ecto.UUID.generate, comment_id: comment_id})
    |> MishkaApi.ContentProtocol.like_comment(conn)
  end

  def delete_comment_like(conn, %{"comment_id" => comment_id}) do
    # action blogs:user_id:view
    CommentLike.delete(Ecto.UUID.generate, comment_id)
    |> MishkaApi.ContentProtocol.delete_comment_like(conn)
  end

  def delete_comment(conn, %{"comment_id" => comment_id}) do
    # action blog:edit
    # change flag of status
    Comment.edit(%{id: comment_id, status: :soft_delete})
    |> MishkaApi.ContentProtocol.delete_comment(conn)
  end

  def destroy_comment(conn, %{"comment_id" => comment_id}) do
    # action *
    Comment.delete(comment_id)
    |> MishkaApi.ContentProtocol.destroy_comment(conn)
  end

  def edit_comment(conn, %{"comment_id" => comment_id, "description" => description}) do
    # action blog:edit
    Comment.edit(%{id: comment_id, description: description})
    |> MishkaApi.ContentProtocol.edit_comment(conn)
  end

  def authors(conn, %{"post_id" => post_id}) do
    # action blog:view
    Author.authors(post_id)
    |> MishkaApi.ContentProtocol.authors(conn)
  end

  def create_tag(conn, %{"title" => _title, "alias_link" => _alias_link, "robots" => _robots} = params) do
     # action blog:create
     Tag.create(params, @allowed_category_fields)
     |> MishkaApi.ContentProtocol.create_tag(conn)
  end

  def edit_tag(conn, %{"tag_id" => tag_id, "title" => _title, "alias_link" => _alias_link, "robots" => _robots} = params) do
    # action blog:edit
    Tag.edit(Map.merge(params, %{"id" => tag_id}), @allowed_category_fields)
     |> MishkaApi.ContentProtocol.edit_tag(conn)
  end

  def create_bookmark(conn, %{"status" => status, "section" => section, "section_id" => section_id}) do
    # action blog:view
    Bookmark.create(%{"status" => status, "section" => section, "section_id" => section_id, "user_id" => Ecto.UUID.generate})
    |> MishkaApi.ContentProtocol.create_bookmark(conn)
  end

  def delete_bookmark(conn, %{"section_id" => section_id}) do
    # action blog:user_id:view
    Bookmark.delete(Ecto.UUID.generate, section_id)
    |> MishkaApi.ContentProtocol.delete_bookmark(conn)
  end

  def create_subscription(conn, %{"section" => section, "section_id" => section_id}) do
    # action blog:view
    Subscription.create(%{"section" => section, "section_id" => section_id, "user_id" => Ecto.UUID.generate})
    |> MishkaApi.ContentProtocol.create_subscription(conn)
  end

  def delete_subscription(conn, %{"section_id" => section_id}) do
    # action blog:user_id:view
    Subscription.delete(Ecto.UUID.generate, section_id)
    |> MishkaApi.ContentProtocol.delete_subscription(conn)
  end

  def add_tag_to_post(conn, %{"post_id" => post_id, "tag_id" => tag_id}) do
    # action blog:create
    TagMapper.create(%{"post_id" => post_id, "tag_id" => tag_id})
    |> MishkaApi.ContentProtocol.add_tag_to_post(conn)
  end

  def remove_post_tag(conn, %{"post_id" => post_id, "tag_id" => tag_id}) do
    # action blog:create
    TagMapper.delete(post_id, tag_id)
    |> MishkaApi.ContentProtocol.remove_post_tag(conn)
  end

  def create_blog_link(conn, params) do
    # action blog:create
    BlogLink.create(params, @blog_link)
    |> MishkaApi.ContentProtocol.create_blog_link(conn)
  end

  def edit_blog_link(conn, %{"blog_link_id" => id} = params) do
    # action blog:create
    BlogLink.edit(Map.merge(params, %{"id" => id}), @blog_link)
    |> MishkaApi.ContentProtocol.edit_blog_link(conn)
  end

  def delete_blog_link(conn, %{"blog_link_id" => id}) do
    # action blog:create
    BlogLink.delete(id)
    |> MishkaApi.ContentProtocol.delete_blog_link(conn)
  end

  def links(conn, %{"page" => page, "section_id" => section_id}) do
    # action blog:view
    BlogLink.links(conditions: {page, 30}, filters: %{section_id: section_id})
    |> MishkaApi.ContentProtocol.links(conn)
  end

  def links(conn, %{"page" => page, "filters" => params}) do
    # action blog:editor
    BlogLink.links(conditions: {page, 30}, filters: params)
    |> MishkaApi.ContentProtocol.links(conn)
  end

  def notifs(conn, %{"page" => page, "filters" => params}) do
    # action *
    Notif.notifs(conditions: {page, 30}, filters: params)
    |> MishkaApi.ContentProtocol.notifs(conn)
  end

  def notifs(conn, %{"page" => page, "status" => status}) when status in [:active, :archived] do
    # action notif:user_id
    Notif.notifs(conditions: {page, 30}, filters: %{user_id: Ecto.UUID.generate, status: status})
    |> MishkaApi.ContentProtocol.notifs(conn)
  end

  def send_notif(conn, %{"status" => _status, "section" => _section} = params) do
    # action *
    Notif.create(params, @notif)
    |> MishkaApi.ContentProtocol.send_notif(conn)
  end
end
