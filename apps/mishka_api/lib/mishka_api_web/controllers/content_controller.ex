defmodule MishkaApiWeb.ContentController do
  use MishkaApiWeb, :controller

  # add ip limitter and os info
  # handel cache of contents


  alias MishkaContent.Blog.{Category, Post, Like, Tag, TagMapper, BlogLink, Author}
  alias MishkaContent.General.{Comment, CommentLike, Bookmark, Notif, Subscription}

  # Activity module needs a good way to store data
  # all the Strong paramiters which is loaded here should be chacked and test ID in create
  # some queries need a extra delete with new paramaters

  def posts(conn, %{"page" => page, "filters" => %{"status" => status} = params})  when status in ["active", "archive"] do
    # action blogs:view
    # list of categories
    filters = Map.take(params, Post.allowed_fields(:string))

    Post.posts(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters))
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def posts(conn, %{"page" => page, "filters" => params}) do
    # action blogs:edit
    # list of categories
    filters = Map.take(params, Post.allowed_fields(:string))

    Post.posts(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters))
    |> MishkaApi.ContentProtocol.posts(conn)
  end

  def post(conn, %{"post_id" => post_id, "status" => status, "comment" =>
  %{
    "page" => _page,
    "filters" => %{"status" => status}
  } = comment}) when status in [:active, :archive] do
    # action blogs:view
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :comment, comment: comment})
  end

  def post(conn, %{"post_id" => post_id, "status" => status, "comment" =>
  %{
    "page" => _page,
    "filters" => _filters
  } = comment})do
    # action blogs:edit
    Post.post(post_id, status)
    |> MishkaApi.ContentProtocol.post(conn, %{type: :comment, comment: comment})
  end

  def post(conn, %{"post_id" => post_id, "status" => status}) when status in ["active", "archive"] do
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
    # action blogs:edit
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

  def comment(conn, %{"filters" => %{"comment_id" => comment_id, "status" => status}}) when status in ["active", "archive"] do
    # action blogs:view
    Comment.comment(filters: %{id: comment_id, status: status})
    |> MishkaApi.ContentProtocol.comment(conn, Comment.allowed_fields(:atom))
  end

  def comment(conn, %{"filters" => filters}) do
    # action blogs:edit
    Comment.show_by_id(filters: filters)
    |> MishkaApi.ContentProtocol.comment(conn, Comment.allowed_fields(:atom))
  end

  def comments(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archive"] do
    # action blogs:edit
    filters = Map.take(params, Comment.allowed_fields(:string))

    Comment.comments(conditions: {page, 20}, filters: MishkaDatabase.convert_string_map_to_atom_map(filters))
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
    filters = Map.take(params, Tag.allowed_fields(:string))
    Tag.tags(conditions: {page, 30}, filters: filters)
    |> MishkaApi.ContentProtocol.tags(conn, Tag.allowed_fields(:atom))
  end

  def post_tags(conn, %{"post_id" => post_id}) do
    Tag.post_tags(post_id)
    |> MishkaApi.ContentProtocol.post_tags(conn, Tag.allowed_fields(:atom))
  end

  def tag_posts(conn, %{"page" => page, "filters" => %{"status" => status} = params}) when status in ["active", "archive"] do
    filters = Map.take(params, Tag.allowed_fields(:string))
    Tag.tag_posts(conditions: {page, 20}, filters: Map.merge(filters, %{"status" => status}))
    |> MishkaApi.ContentProtocol.tag_posts(conn, Tag.allowed_fields(:atom))
  end

  def tag_posts(conn, %{"page" => page, "filters" => params}) do
    filters = Map.take(params, Tag.allowed_fields(:string))
    Tag.tag_posts(conditions: {page, 20}, filters: filters)
    |> MishkaApi.ContentProtocol.tag_posts(conn, Tag.allowed_fields(:atom))
  end

  # def create_bookmark(conn, %{"status" => status, "section" => section, "section_id" => section_id}) do
  #   # action blog:view
  #   Bookmark.create(%{"status" => status, "section" => section, "section_id" => section_id, "user_id" => Ecto.UUID.generate})
  #   |> MishkaApi.ContentProtocol.create_bookmark(conn)
  # end

  # def delete_bookmark(conn, %{"section_id" => section_id}) do
  #   # action blog:user_id:view
  #   Bookmark.delete(Ecto.UUID.generate, section_id)
  #   |> MishkaApi.ContentProtocol.delete_bookmark(conn)
  # end

  # def create_subscription(conn, %{"section" => section, "section_id" => section_id}) do
  #   # action blog:view
  #   Subscription.create(%{"section" => section, "section_id" => section_id, "user_id" => Ecto.UUID.generate})
  #   |> MishkaApi.ContentProtocol.create_subscription(conn)
  # end

  # def delete_subscription(conn, %{"section_id" => section_id}) do
  #   # action blog:user_id:view
  #   Subscription.delete(Ecto.UUID.generate, section_id)
  #   |> MishkaApi.ContentProtocol.delete_subscription(conn)
  # end

  # def create_blog_link(conn, params) do
  #   # action blog:create
  #   BlogLink.create(params, @blog_link)
  #   |> MishkaApi.ContentProtocol.create_blog_link(conn)
  # end

  # def edit_blog_link(conn, %{"blog_link_id" => id} = params) do
  #   # action blog:create
  #   BlogLink.edit(Map.merge(params, %{"id" => id}), @blog_link)
  #   |> MishkaApi.ContentProtocol.edit_blog_link(conn)
  # end

  # def delete_blog_link(conn, %{"blog_link_id" => id}) do
  #   # action blog:create
  #   BlogLink.delete(id)
  #   |> MishkaApi.ContentProtocol.delete_blog_link(conn)
  # end

  # def links(conn, %{"page" => page, "section_id" => section_id}) do
  #   # action blog:view
  #   BlogLink.links(conditions: {page, 30}, filters: %{section_id: section_id})
  #   |> MishkaApi.ContentProtocol.links(conn)
  # end

  # def links(conn, %{"page" => page, "filters" => params}) do
  #   # action blog:editor
  #   BlogLink.links(conditions: {page, 30}, filters: params)
  #   |> MishkaApi.ContentProtocol.links(conn)
  # end

  # def notifs(conn, %{"page" => page, "filters" => params}) do
  #   # action *
  #   Notif.notifs(conditions: {page, 30}, filters: params)
  #   |> MishkaApi.ContentProtocol.notifs(conn)
  # end

  # def notifs(conn, %{"page" => page, "status" => status}) when status in [:active, :archived] do
  #   # action notif:user_id
  #   Notif.notifs(conditions: {page, 30}, filters: %{user_id: Ecto.UUID.generate, status: status})
  #   |> MishkaApi.ContentProtocol.notifs(conn)
  # end

  # def send_notif(conn, %{"status" => _status, "section" => _section} = params) do
  #   # action *
  #   Notif.create(params, @notif)
  #   |> MishkaApi.ContentProtocol.send_notif(conn)
  # end

  # def authors(conn, %{"post_id" => post_id}) do
  #   # action blog:view
  #   Author.authors(post_id)
  #   |> MishkaApi.ContentProtocol.authors(conn)
  # end
end
