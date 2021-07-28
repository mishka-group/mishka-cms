defmodule MishkaApiWeb.ContentController do
  use MishkaApiWeb, :controller

  # add ip limitter and os info
  # handel cache of contents


  alias MishkaContent.Blog.{Category, Post, Like, Tag, TagMapper, BlogLink, Author}
  alias MishkaContent.General.{Comment, CommentLike, Bookmark, Notif, Subscription}

  # Activity module needs a good way to store data
  # all the Strong paramiters which is loaded here should be chacked and test ID in create
  # some queries need a extra delete with new paramaters

  def posts(conn, %{"page" => page, "filters" => %{"status" => status} = params})  when status in ["active", "archived"] do
    # action blogs:view
    # list of categories
    filters = Map.take(params, Post.allowed_fields(:string))

    # TODO: nil should be replaced with user_id
    Post.posts(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters), user_id: nil)
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def posts(conn, %{"page" => page, "filters" => params}) do
    # action blogs:edit
    # list of categories
    filters = Map.take(params, Post.allowed_fields(:string))

    # TODO: nil should be replaced with user_id
    Post.posts(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters), user_id: nil)
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def post(conn, %{"alias_link" => alias_link, "status" => status, "comment" =>
  %{
    "page" => _page,
    "filters" => %{"status" => status}
  } = comment}) when status in [:active, :archive] do
    # action blogs:view
    Post.post(alias_link, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :comment, comment: comment})
  end

  def post(conn, %{"alias_link" => alias_link, "status" => status, "comment" =>
  %{
    "page" => _page,
    "filters" => _filters
  } = comment})do
    # action blogs:edit
    Post.post(alias_link, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :comment, comment: comment})
  end

  def post(conn, %{"post_id" => post_id, "status" => status}) when status in ["active", "archived"] do
    # action blogs:view
    # list of categories
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :none_comment})
  end

  def post(conn, %{"post_id" => post_id, "status" => status})do
    # action blogs:edit
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :none_comment})
  end

  def create_post(conn, params) do
    # action blogs:edit
    # action blogs:create
    Post.create(params, Post.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_post(conn, Post.allowed_fields(:atom))
  end

  def edit_post(conn, %{"post_id" => post_id} = params) do

    # MishkaUser.Acl.Access.permittes?("posts:edit", "27ad720a-4b97-4c7b-a175-396be2c95d1c")

    Post.edit(Map.merge(params, %{"id" => post_id}), Post.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_post(conn, Post.allowed_fields(:atom))
  end

  def delete_post(conn, %{"post_id" => post_id}) do
    # action blogs:edit
    # change flag of status
    Post.edit(%{id: post_id, status: :soft_delete})
    |> MishkaApi.ContentProtocol.delete_post(conn, Post.allowed_fields(:atom))
  end

  def destroy_post(conn, %{"post_id" => post_id}) do
    # action blogs:*
    Post.delete(post_id)
    |> MishkaApi.ContentProtocol.destroy_post(conn, Post.allowed_fields(:atom))
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
  def create_category(conn, params) do
    # action blogs:edit
    Category.create(params, Category.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_category(conn, Category.allowed_fields(:atom))
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

  def like_post(conn, %{"post_id" => post_id}) do
    # action blogs:view
    Like.create(%{user_id: conn.assigns.user_id, post_id: post_id})
    |> MishkaApi.ContentProtocol.like_post(conn, Like.allowed_fields(:atom))
  end

  def delete_post_like(conn, %{"post_id" => post_id}) do
    # action blogs:user_id:view
    Like.delete(conn.assigns.user_id, post_id)
    |> MishkaApi.ContentProtocol.delete_post_like(conn, Like.allowed_fields(:atom))
  end

  def comment(conn, %{"filters" => %{"comment_id" => comment_id, "status" => status}}) when status in ["active", "archived"] do
    # action blogs:view
    Comment.comment(filters: %{id: comment_id, status: status})
    |> MishkaApi.ContentProtocol.comment(conn, Comment.allowed_fields(:atom))
  end

  def comment(conn, %{"filters" => params}) do
    # action blogs:edit
    filters =
      Map.take(params, Comment.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()

    Comment.comment(filters: filters)
    |> MishkaApi.ContentProtocol.comment(conn, Comment.allowed_fields(:atom))
  end

  def comments(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archived"] do
    # action blogs:edit
    filters =
      Map.take(params, Comment.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()

    Comment.comments(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.comments(conn, Comment.allowed_fields(:atom))
  end

  def comments(conn, %{"page" => page, "filters" => params}) do
    # action blogs:edit
    filters = Map.take(params, Comment.allowed_fields(:string))

    Comment.comments(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters))
    |> MishkaApi.ContentProtocol.comments(conn, Comment.allowed_fields(:atom))
  end

  def create_comment(conn, %{"section_id" => _section_id, "description" => _description} = params) do
    # action blogs:view
    Comment.create(Map.merge(params, %{"priority" => "none", "section" => "blog_post", "status" => "active", "user_id" => conn.assigns.user_id}), Comment.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_comment(conn, Comment.allowed_fields(:atom))
  end

  def edit_comment(conn, params) do
    # action blog:edit
    Comment.edit(params, Comment.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_comment(conn, Comment.allowed_fields(:atom))
  end

  def delete_comment(conn, %{"comment_id" => comment_id}) do
    # action blog:edit
    Comment.delete(conn.assigns.user_id, comment_id)
    |> MishkaApi.ContentProtocol.delete_comment(conn, Comment.allowed_fields(:atom))
  end

  def delete_comment(conn, %{"user_id" => user_id,"comment_id" => comment_id}) do
    # action blog:edit
    Comment.delete(user_id, comment_id)
    |> MishkaApi.ContentProtocol.delete_comment(conn, Comment.allowed_fields(:atom))
  end

  def destroy_comment(conn, %{"comment_id" => comment_id}) do
    # action *
    Comment.delete(comment_id)
    |> MishkaApi.ContentProtocol.destroy_comment(conn, Comment.allowed_fields(:atom))
  end

  def like_comment(conn, %{"comment_id" => comment_id}) do
    # action *:view
    CommentLike.create(%{user_id: conn.assigns.user_id, comment_id: comment_id})
    |> MishkaApi.ContentProtocol.like_comment(conn, CommentLike.allowed_fields(:atom))
  end

  def delete_comment_like(conn, %{"comment_id" => comment_id}) do
    # action blogs:user_id:view
    CommentLike.delete(conn.assigns.user_id, comment_id)
    |> MishkaApi.ContentProtocol.delete_comment_like(conn, CommentLike.allowed_fields(:atom))
  end

  def create_tag(conn, %{"title" => _title, "alias_link" => _alias_link, "robots" => _robots} = params) do
     # action blog:create
     Tag.create(params, Tag.allowed_fields(:string))
     |> MishkaApi.ContentProtocol.create_tag(conn, Tag.allowed_fields(:atom))
  end

  def edit_tag(conn, %{"tag_id" => tag_id} = params) do
    # action blog:edit
    Tag.edit(Map.merge(params, %{"id" => tag_id}), Tag.allowed_fields(:string))
     |> MishkaApi.ContentProtocol.edit_tag(conn, Tag.allowed_fields(:atom))
  end

  def delete_tag(conn, %{"tag_id" => tag_id}) do
    # action *
    Tag.delete(tag_id)
     |> MishkaApi.ContentProtocol.delete_tag(conn, Tag.allowed_fields(:atom))
  end

  def add_tag_to_post(conn, %{"post_id" => post_id, "tag_id" => tag_id}) do
    # action blog:create
    TagMapper.create(%{"post_id" => post_id, "tag_id" => tag_id})
    |> MishkaApi.ContentProtocol.add_tag_to_post(conn, TagMapper.allowed_fields(:atom))
  end

  def remove_post_tag(conn, %{"post_id" => post_id, "tag_id" => tag_id}) do
    # action blog:create
    TagMapper.delete(post_id, tag_id)
    |> MishkaApi.ContentProtocol.remove_post_tag(conn, TagMapper.allowed_fields(:atom))
  end

  def tags(conn, %{"page" => page, "filters" => params}) do
    # action blog:view
    filters = Map.take(params, Tag.allowed_fields(:string))
    Tag.tags(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.tags(conn, Tag.allowed_fields(:atom))
  end

  def post_tags(conn, %{"post_id" => post_id}) do
    # action blog:view
    Tag.post_tags(post_id)
    |> MishkaApi.ContentProtocol.post_tags(conn, Tag.allowed_fields(:atom))
  end

  def tag_posts(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archived"] do
    # action blog:view
    filters = Map.take(params, Tag.allowed_fields(:string))
    Tag.tag_posts(conditions: {page, 20}, filters: Map.merge(filters, %{"status" => status}))
    |> MishkaApi.ContentProtocol.tag_posts(conn, Tag.allowed_fields(:atom))
  end

  def tag_posts(conn, %{"page" => page, "filters" => params}) do
    # action blog:edit
    filters = Map.take(params, Tag.allowed_fields(:string))
    Tag.tag_posts(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.tag_posts(conn, Tag.allowed_fields(:atom))
  end

  def create_bookmark(conn, %{"section" => section, "section_id" => section_id}) do
    # action blog:view
    Bookmark.create(%{"status" => "active", "section" => section, "section_id" => section_id, "user_id" => conn.assigns.user_id})
    |> MishkaApi.ContentProtocol.create_bookmark(conn, Bookmark.allowed_fields(:atom))
  end

  def delete_bookmark(conn, %{"section_id" => section_id}) do
    # action blog:user_id:view
    Bookmark.delete(conn.assigns.user_id, section_id)
    |> MishkaApi.ContentProtocol.delete_bookmark(conn, Bookmark.allowed_fields(:atom))
  end

  def create_subscription(conn, %{"section" => section, "section_id" => section_id}) do
    # action blog:view
    Subscription.create(%{"section" => section, "section_id" => section_id, "user_id" => conn.assigns.user_id})
    |> MishkaApi.ContentProtocol.create_subscription(conn, Subscription.allowed_fields(:atom))
  end

  def delete_subscription(conn, %{"section_id" => section_id}) do
    # action blog:user_id:view
    Subscription.delete(conn.assigns.user_id, section_id)
    |> MishkaApi.ContentProtocol.delete_subscription(conn, Subscription.allowed_fields(:atom))
  end

  def create_blog_link(conn, params) do
    # action blog:create
    BlogLink.create(params, BlogLink.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_blog_link(conn, BlogLink.allowed_fields(:atom))
  end

  def edit_blog_link(conn, %{"blog_link_id" => id} = params) do
    # action blog:create
    BlogLink.edit(Map.merge(params, %{"id" => id}), BlogLink.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_blog_link(conn, BlogLink.allowed_fields(:atom))
  end

  def delete_blog_link(conn, %{"blog_link_id" => id}) do
    # action blog:create
    BlogLink.delete(id)
    |> MishkaApi.ContentProtocol.delete_blog_link(conn, BlogLink.allowed_fields(:atom))
  end

  def links(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archived"] do
    # action blog:view
    filters = Map.take(params, BlogLink.allowed_fields(:string))
    BlogLink.links(conditions: {page, 30}, filters: Map.merge(filters, %{"status" => status}))
    |> MishkaApi.ContentProtocol.links(conn, BlogLink.allowed_fields(:atom))
  end

  def links(conn, %{"page" => page, "filters" => params}) do
    # action blog:edit
    filters = Map.take(params, BlogLink.allowed_fields(:string))
    BlogLink.links(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.links(conn, BlogLink.allowed_fields(:atom))
  end

  def notifs(conn, %{"type" => "client", "page" => page, "filters" => params}) do
    # action view:user_id
    filters =
      Map.take(params, Notif.allowed_fields(:string))
      |> Map.merge(%{"user_id" => conn.assigns.user_id})
      |> MishkaDatabase.convert_string_map_to_atom_map()

    Notif.notifs(conditions: {page, 30, :client}, filters: filters)
    |> MishkaApi.ContentProtocol.notifs(conn, Notif.allowed_fields(:atom))
  end

  def notifs(conn, %{"page" => page, "filters" => params}) do
    # action *
    filters =
      Map.take(params, Notif.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()

    Notif.notifs(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.notifs(conn, Notif.allowed_fields(:atom))
  end

  def send_notif(conn, params) do
    # action *
    Notif.create(params, Notif.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.send_notif(conn, Notif.allowed_fields(:atom))
  end

  def authors(conn, %{"post_id" => post_id}) do
    # action blog:view
    Author.authors(post_id)
    |> MishkaApi.ContentProtocol.authors(conn, Author.allowed_fields(:atom))
  end

  # create blog author
  def create_author(conn, params) do
    Author.create(params, Author.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_author(conn, Author.allowed_fields(:atom))
  end

  def delete_author(conn, %{"post_id" => post_id, "user_id" => user_id}) do
    Author.delete(user_id, post_id)
    |> MishkaApi.ContentProtocol.delete_author(conn, Author.allowed_fields(:atom))
  end
end
