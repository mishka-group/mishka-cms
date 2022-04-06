defmodule MishkaApiWeb.ContentController do
  use MishkaApiWeb, :controller

  alias MishkaContent.Blog.{Category, Post, Like, Tag, TagMapper, BlogLink, Author}
  alias MishkaContent.General.{Comment, CommentLike, Bookmark, Notif, Subscription}

  def posts(conn, %{"page" => page, "filters" => %{"status" => status} = params})  when status in ["active", "archived"] do
    filters = Map.take(params, Post.allowed_fields(:string))
    Post.posts(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters), user_id: Map.get(conn.assigns, :user_id))
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def editor_posts(conn, %{"page" => page, "filters" => params}) when is_map(params) do
    filters = Map.take(params, Post.allowed_fields(:string))
    Post.posts(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters), user_id: Map.get(conn.assigns, :user_id))
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def post(conn, %{"alias_link" => alias_link, "status" => status, "comment" => %{"page" => _page, "filters" => %{"status" => status}} = comment}) when status in ["active", "archive"] do
    Post.post(alias_link, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :comment, comment: comment})
  end

  def post(conn, %{"alias_link" => alias_link, "status" => status}) when status in ["active", "archived"] do
    Post.post(alias_link, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :none_comment})
  end

  def editor_post(conn, %{"alias_link" => alias_link, "status" => status, "comment" => %{"page" => _page, "filters" => _filters} = comment})do
    Post.post(alias_link, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :comment, comment: MishkaDatabase.convert_string_map_to_atom_map(comment)})
  end

  def editor_post(conn, %{"alias_link" => alias_link, "status" => status})do
    Post.post(alias_link, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :none_comment})
  end

  def create_post(conn, params) do
    Post.create(params, Post.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_post(conn, Post.allowed_fields(:atom))
  end

  def edit_post(conn, %{"post_id" => post_id} = params) do
    Post.edit(Map.merge(params, %{"id" => post_id}), Post.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_post(conn, Post.allowed_fields(:atom))
  end

  def delete_post(conn, %{"post_id" => post_id}) do
    Post.edit(%{id: post_id, status: :soft_delete})
    |> MishkaApi.ContentProtocol.delete_post(conn, Post.allowed_fields(:atom))
  end

  def destroy_post(conn, %{"post_id" => post_id}) do
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

  def editor_categories(conn, %{"filters" => params}) when is_map(params) do
    Category.categories(filters: MishkaDatabase.convert_string_map_to_atom_map(params))
    |> MishkaApi.ContentProtocol.categories(conn)
  end

  def categories(conn, _params) do
    Category.categories(filters: %{status: :active})
    |> MishkaApi.ContentProtocol.categories(conn)
  end
  def create_category(conn, params) do
    Category.create(params, Category.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_category(conn, Category.allowed_fields(:atom))
  end

  def edit_category(conn, %{"category_id" => category_id} = params) do
    Category.edit(Map.merge(params, %{"id" => category_id}), Category.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_category(conn, Category.allowed_fields(:atom))
  end

  def delete_category(conn, %{"category_id" => category_id}) do
    Category.edit(%{id: category_id, status: :soft_delete})
    |> MishkaApi.ContentProtocol.delete_category(conn, Category.allowed_fields(:atom))
  end

  def destroy_category(conn, %{"category_id" => category_id}) do
    Category.delete(category_id)
    |> MishkaApi.ContentProtocol.destroy_category(conn, Category.allowed_fields(:atom))
  end

  def like_post(conn, %{"post_id" => post_id}) do
    Like.create(%{user_id: Map.get(conn.assigns, :user_id), post_id: post_id})
    |> MishkaApi.ContentProtocol.like_post(conn, Like.allowed_fields(:atom))
  end

  def delete_post_like(conn, %{"post_id" => post_id}) do
    Like.delete(Map.get(conn.assigns, :user_id), post_id)
    |> MishkaApi.ContentProtocol.delete_post_like(conn, Like.allowed_fields(:atom))
  end

  def comment(conn, %{"filters" => %{"comment_id" => comment_id, "status" => status}}) when status in ["active", "archived"] do
    Comment.comment(filters: %{id: comment_id, status: status}, user_id: Map.get(conn.assigns, :user_id))
    |> MishkaApi.ContentProtocol.comment(conn, Comment.allowed_fields(:atom))
  end

  def comments(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archived"] do
    filters =
      Map.take(params, Comment.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Comment.comments(conditions: {page, 20}, filters: filters, user_id: Map.get(conn.assigns, :user_id))
    |> MishkaApi.ContentProtocol.comments(conn, Comment.allowed_fields(:atom))
  end

  def editor_comment(conn, %{"filters" => params}) when is_map(params) do
    filters =
      Map.take(params, Comment.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Comment.comment(filters: filters, user_id: Map.get(conn.assigns, :user_id))
    |> MishkaApi.ContentProtocol.comment(conn, Comment.allowed_fields(:atom))
  end

  def editor_comments(conn, %{"page" => page, "filters" => params}) when is_map(params) do
    filters = Map.take(params, Comment.allowed_fields(:string))
    Comment.comments(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters), user_id: Map.get(conn.assigns, :user_id))
    |> MishkaApi.ContentProtocol.comments(conn, Comment.allowed_fields(:atom))
  end

  def create_comment(conn, %{"section_id" => _section_id, "description" => _description} = params) do
    Comment.create(Map.merge(params, %{"priority" => "none", "section" => "blog_post", "status" => "active", "user_id" => Map.get(conn.assigns, :user_id)}), Comment.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_comment(conn, Comment.allowed_fields(:atom))
  end

  def edit_comment(conn, params) do
    Comment.edit(params, Comment.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_comment(conn, Comment.allowed_fields(:atom))
  end

  def delete_comment(conn, %{"comment_id" => comment_id}) do
    Comment.delete(Map.get(conn.assigns, :user_id), comment_id)
    |> MishkaApi.ContentProtocol.delete_comment(conn, Comment.allowed_fields(:atom))
  end

  def delete_comment(conn, %{"user_id" => user_id,"comment_id" => comment_id}) do
    Comment.delete(user_id, comment_id)
    |> MishkaApi.ContentProtocol.delete_comment(conn, Comment.allowed_fields(:atom))
  end

  def destroy_comment(conn, %{"comment_id" => comment_id}) do
    Comment.delete(comment_id)
    |> MishkaApi.ContentProtocol.destroy_comment(conn, Comment.allowed_fields(:atom))
  end

  def like_comment(conn, %{"comment_id" => comment_id}) do
    CommentLike.create(%{user_id: Map.get(conn.assigns, :user_id), comment_id: comment_id})
    |> MishkaApi.ContentProtocol.like_comment(conn, CommentLike.allowed_fields(:atom))
  end

  def delete_comment_like(conn, %{"comment_id" => comment_id}) do
    CommentLike.delete(Map.get(conn.assigns, :user_id), comment_id)
    |> MishkaApi.ContentProtocol.delete_comment_like(conn, CommentLike.allowed_fields(:atom))
  end

  def create_tag(conn, %{"title" => _title, "alias_link" => _alias_link, "robots" => _robots} = params) do
     Tag.create(params, Tag.allowed_fields(:string))
     |> MishkaApi.ContentProtocol.create_tag(conn, Tag.allowed_fields(:atom))
  end

  def edit_tag(conn, %{"tag_id" => tag_id} = params) do
    Tag.edit(Map.merge(params, %{"id" => tag_id}), Tag.allowed_fields(:string))
     |> MishkaApi.ContentProtocol.edit_tag(conn, Tag.allowed_fields(:atom))
  end

  def delete_tag(conn, %{"tag_id" => tag_id}) do
    Tag.delete(tag_id)
     |> MishkaApi.ContentProtocol.delete_tag(conn, Tag.allowed_fields(:atom))
  end

  def add_tag_to_post(conn, %{"post_id" => post_id, "tag_id" => tag_id}) do
    TagMapper.create(%{"post_id" => post_id, "tag_id" => tag_id})
    |> MishkaApi.ContentProtocol.add_tag_to_post(conn, TagMapper.allowed_fields(:atom))
  end

  def remove_post_tag(conn, %{"post_id" => post_id, "tag_id" => tag_id}) do
    TagMapper.delete(post_id, tag_id)
    |> MishkaApi.ContentProtocol.remove_post_tag(conn, TagMapper.allowed_fields(:atom))
  end

  def tags(conn, %{"page" => page, "filters" => params}) when is_map(params) do
    filters =
      Map.take(params, Tag.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Tag.tags(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.tags(conn, Tag.allowed_fields(:atom))
  end

  def post_tags(conn, %{"post_id" => post_id}) do
    Tag.post_tags(post_id)
    |> MishkaApi.ContentProtocol.post_tags(conn, Tag.allowed_fields(:atom))
  end

  def tag_posts(conn, %{"page" => page, "filters" => %{"post_status" => post_status} = params}) when post_status in ["active", "archived"] do
    filters =
      Map.take(params, Tag.allowed_fields(:string) ++ ["post_status"])
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Tag.tag_posts(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.tag_posts(conn, Tag.allowed_fields(:atom))
  end

  def editor_tag_posts(conn, %{"page" => page, "filters" => params}) when is_map(params) do
    filters =
      Map.take(params, Tag.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Tag.tag_posts(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.tag_posts(conn, Tag.allowed_fields(:atom))
  end

  def create_bookmark(conn, %{"section" => section, "section_id" => section_id}) do
    Bookmark.create(%{"status" => "active", "section" => section, "section_id" => section_id, "user_id" => Map.get(conn.assigns, :user_id)})
    |> MishkaApi.ContentProtocol.create_bookmark(conn, Bookmark.allowed_fields(:atom))
  end

  def delete_bookmark(conn, %{"section_id" => section_id}) do
    Bookmark.delete(Map.get(conn.assigns, :user_id), section_id)
    |> MishkaApi.ContentProtocol.delete_bookmark(conn, Bookmark.allowed_fields(:atom))
  end

  def create_subscription(conn, %{"section" => section, "section_id" => section_id}) do
    Subscription.create(%{"section" => section, "section_id" => section_id, "user_id" => Map.get(conn.assigns, :user_id)})
    |> MishkaApi.ContentProtocol.create_subscription(conn, Subscription.allowed_fields(:atom))
  end

  def delete_subscription(conn, %{"section_id" => section_id}) do
    Subscription.delete(Map.get(conn.assigns, :user_id), section_id)
    |> MishkaApi.ContentProtocol.delete_subscription(conn, Subscription.allowed_fields(:atom))
  end

  def create_blog_link(conn, params) do
    BlogLink.create(params, BlogLink.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_blog_link(conn, BlogLink.allowed_fields(:atom))
  end

  def edit_blog_link(conn, %{"blog_link_id" => id} = params) do
    BlogLink.edit(Map.merge(params, %{"id" => id}), BlogLink.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.edit_blog_link(conn, BlogLink.allowed_fields(:atom))
  end

  def delete_blog_link(conn, %{"blog_link_id" => id}) do
    BlogLink.delete(id)
    |> MishkaApi.ContentProtocol.delete_blog_link(conn, BlogLink.allowed_fields(:atom))
  end

  def links(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archived"] do
    filters = Map.take(params, BlogLink.allowed_fields(:string))
    BlogLink.links(conditions: {page, 30}, filters: Map.merge(filters, %{"status" => status}))
    |> MishkaApi.ContentProtocol.links(conn, BlogLink.allowed_fields(:atom))
  end

  def editor_links(conn, %{"page" => page, "filters" => params}) when is_map(params) do
    filters = Map.take(params, BlogLink.allowed_fields(:string))
    BlogLink.links(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.links(conn, BlogLink.allowed_fields(:atom))
  end

  def notifs(conn, %{"type" => "client", "page" => page, "filters" => params}) when is_map(params) do
    filters =
      Map.take(params, Notif.allowed_fields(:string))
      |> Map.merge(%{"user_id" => Map.get(conn.assigns, :user_id)})
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Notif.notifs(conditions: {page, 30, :client}, filters: filters)
    |> MishkaApi.ContentProtocol.notifs(conn, Notif.allowed_fields(:atom))
  end

  def editor_notifs(conn, %{"page" => page, "filters" => params}) when is_map(params) do
    filters =
      Map.take(params, Notif.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()
    Notif.notifs(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.notifs(conn, Notif.allowed_fields(:atom))
  end

  def send_notif(conn, params) do
    Notif.create(params, Notif.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.send_notif(conn, Notif.allowed_fields(:atom))
  end

  def authors(conn, %{"post_id" => post_id}) do
    Author.authors(post_id)
    |> MishkaApi.ContentProtocol.authors(conn, Author.allowed_fields(:atom))
  end

  def create_author(conn, params) do
    Author.create(params, Author.allowed_fields(:string))
    |> MishkaApi.ContentProtocol.create_author(conn, Author.allowed_fields(:atom))
  end

  def delete_author(conn, %{"post_id" => post_id, "user_id" => user_id}) do
    Author.delete(user_id, post_id)
    |> MishkaApi.ContentProtocol.delete_author(conn, Author.allowed_fields(:atom))
  end
end
