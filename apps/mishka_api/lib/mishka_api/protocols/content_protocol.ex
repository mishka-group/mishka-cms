defprotocol MishkaApi.ContentProtocol do
  @fallback_to_any true

  def posts(parametr, conn)

  def post(parametr, conn, type)

  def create_post(parametr, conn, allowed_fields)

  def create_category(parametr, conn, allowed_fields)

  def like_post(parametr, conn, allowed_fields)

  def delete_post_like(parametr, conn, allowed_fields)

  def edit_post(parametr, conn, allowed_fields)

  def delete_post(parametr, conn, allowed_fields)

  def destroy_post(parametr, conn, allowed_fields)

  def edit_category(parametr, conn, allowed_fields)

  def delete_category(parametr, conn, allowed_fields)

  def destroy_category(parametr, conn, allowed_fields)

  def comment(parametr, conn, allowed_fields)

  def comments(parametr, conn, allowed_fields)

  def create_comment(parametr, conn, allowed_fields)

  def like_comment(parametr, conn, allowed_fields)

  def delete_comment_like(parametr, conn, allowed_fields)

  def delete_comment(parametr, conn, allowed_fields)

  def destroy_comment(parametr, conn, allowed_fields)

  def edit_comment(parametr, conn, allowed_fields)

  def authors(parametr, conn, allowed_fields)

  def create_tag(parametr, conn, allowed_fields)

  def edit_tag(parametr, conn, allowed_fields)

  def delete_tag(parametr, conn, allowed_fields)

  def tags(parametr, conn, allowed_fields)

  def post_tags(parametr, conn, allowed_fields)

  def tag_posts(parametr, conn, allowed_fields)

  def create_bookmark(parametr, conn, allowed_fields)

  def delete_bookmark(parametr, conn, allowed_fields)

  def create_subscription(parametr, conn, allowed_fields)

  def delete_subscription(parametr, conn, allowed_fields)

  def add_tag_to_post(parametr, conn, allowed_fields)

  def remove_post_tag(parametr, conn, allowed_fields)

  def create_blog_link(parametr, conn, allowed_fields)

  def edit_blog_link(parametr, conn, allowed_fields)

  def delete_blog_link(parametr, conn, allowed_fields)

  def links(parametr, conn, allowed_fields)

  def send_notif(parametr, conn, allowed_fields)

  def notifs(parametr, conn, allowed_fields)

  def categories(parametr, conn)

  def category(parametr, conn, allowed_fields)

  def create_author(parametr, conn, allowed_fields)

  def delete_author(parametr, conn, allowed_fields)
end

defimpl MishkaApi.ContentProtocol, for: Any do
  use MishkaApiWeb, :controller
  @request_error_tag :content
  alias MishkaContent.General.Comment
  alias MishkaContent.Blog.BlogLink
  require MishkaTranslator.Gettext

  def posts(params, conn) do
    json_output(conn, params: params, action: :posts)
  end
  def post(nil, conn, _type) do
    not_available_record(action: :post, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def post(parametr, conn, %{type: :comment, comment: comment}) do
    filters =
      Map.take(comment["filters"], Comment.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()

    comments = Comment.comments(conditions: {comment["page"], 20}, filters: filters, user_id: Map.get(conn.assigns, :user_id))
    links = BlogLink.links(filters: %{section_id: parametr.id, status: parametr.status})

    conn
    |> put_status(200)
    |> json(%{
      action: :post,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      post_info: Map.merge(parametr, %{
        comments: %{
          entries: comments.entries,
          page_number: comments.page_number,
          page_size: comments.page_size,
          total_entries: comments.total_entries,
          total_pages: comments.total_pages
        },
        links: links
      }),
    })
  end

  def post(parametr, conn, %{type: :none_comment}) do
    links = BlogLink.links(filters: %{section_id: parametr.id})
    conn
    |> put_status(200)
    |> json(%{
      action: :post,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      post_info: Map.merge(parametr, %{links: links}),
    })
  end

  def create_post({:error, :add, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_post)
  end

  def create_post({:ok, :add, :post, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_post",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_post", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_post, output_name: "post_info")
  end

  def edit_post({:error, :edit, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :edit_post)
  end

  def edit_post({:ok, :edit, :post, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_post",
      section_id: repo_data.id,
      action: "edit",
      priority: "medium",
      status: "info"
    }, %{user_action: "edit_post", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :edit_post, output_name: "post_info")
  end

  def edit_post({:error, :edit, _, :post}, conn, _allowed_fields) do
    not_available_record(action: :edit_post, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_post({:error, :edit, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_post)
  end

  def delete_post({:ok, :edit, :post, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_post",
      section_id: repo_data.id,
      action: "delete",
      priority: "high",
      status: "info"
    }, %{user_action: "delete_post", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_post, output_name: "post_info")
  end

  def delete_post({:error, :edit, _, :post}, conn, _allowed_fields) do
    not_available_record(action: :delete_post, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def destroy_post({:ok, :delete, :post, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_post",
      section_id: repo_data.id,
      action: "destroy",
      priority: "high",
      status: "info"
    }, %{user_action: "destroy_post", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :destroy_post, output_name: "post_info")
  end

  def destroy_post({:error, :delete, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :destroy_post)
  end

  def destroy_post({:error, :delete, _, :post}, conn, _allowed_fields) do
    not_available_record(action: :destroy_post, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def create_category({:error, :add, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_category)
  end

  def create_category({:ok, :add, :category, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_category",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_category", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_category, output_name: "category_info")
  end

  def edit_category({:error, :edit, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :edit_category, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def edit_category({:ok, :edit, :category, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_category",
      section_id: repo_data.id,
      action: "edit",
      priority: "medium",
      status: "info",
    }, %{user_action: "edit_category", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :edit_category, output_name: "category_info")
  end

  def edit_category({:error, :edit, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :edit_category)
  end

  def delete_category({:ok, :edit, :category, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_category",
      section_id: repo_data.id,
      action: "delete",
      priority: "high",
      status: "info"
    }, %{user_action: "delete_category", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_category, output_name: "category_info")
  end

  def delete_category({:error, :edit, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :delete_category, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_category({:error, :edit, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_category)
  end

  def destroy_category({:error, :delete, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :destroy_category)
  end

  def destroy_category({:error, :delete, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :destroy_category, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def destroy_category({:ok, :delete, :category, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_category",
      section_id: repo_data.id,
      action: "destroy",
      priority: "high",
      status: "info"
    }, %{user_action: "destroy_category", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :destroy_category, output_name: "category_info")
  end

  def categories(parametr, conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :categories,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      categories: parametr
    })
  end

  def category({:error, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :category, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "خطایی در فراخوانی داده مورد نیاز شما پیش آماده است"))
  end

  def category({:ok, _, :category, category_info}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :category,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      category_info: Map.take(category_info, allowed_fields)
    })
  end

  def like_post({:ok, :add, :post_like, repo_data}, conn, allowed_fields) do
    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :like_post, output_name: "like_info")
  end

  def like_post({:error, :add, :post_like, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :like_post)
  end

  def delete_post_like({:error, :delete, :post_like, :not_found}, conn, _allowed_fields) do
    conn
    |> put_status(404)
    |> json(%{
      action: :delete_post_like,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "خطایی در پسند کردن پست مورد نظر پیش آماده است"),
      errors: :not_found
    })
  end

  def delete_post_like({:ok, :delete, :post_like, repo_data}, conn, allowed_fields) do
    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_post_like, output_name: "like_info")
  end

  def delete_post_like({:error, :delete, :post_like, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_post_like)
  end

  def delete_post_like({:error, :delete, _, :post_like}, conn, _allowed_fields) do
    not_available_record(action: :post_like, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def comment(nil, conn, _allowed_fields) do
    not_available_record(action: :comment, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def comment(parametr, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :comment,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      comment_info: Map.take(parametr, allowed_fields)
    })
  end

  def comments(params, conn, _allowed_fields) do
    json_output(conn, params: params, action: :comments)
  end

  def create_comment({:error, :add, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_comment)
  end

  def create_comment({:ok, :add, :comment, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "comment",
      section_id: repo_data.id,
      action: "add",
      priority: "low",
      status: "info"
    }, %{user_action: "create_comment", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_comment, output_name: "comment_info")
  end

  def edit_comment({:ok, :edit, :comment, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "comment",
      section_id: repo_data.id,
      action: "edit",
      priority: "low",
      status: "info"
    }, %{user_action: "edit_comment", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :edit_comment, output_name: "comment_info")
  end

  def edit_comment({:error, :edit, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :edit_comment)
  end

  def edit_comment({:error, :edit, _, :comment}, conn, _allowed_fields) do
    not_available_record(action: :edit_comment, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def like_comment({:ok, :add, :comment_like, repo_data}, conn, allowed_fields) do
    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :like_comment, output_name: "comment_like_info")
  end

  def like_comment({:error, :add, :comment_like, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :like_comment)
  end

  def delete_comment_like({:error, :delete, :comment_like, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment_like, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_comment_like({:error, :delete, :comment_like, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_comment_like)
  end

  def delete_comment_like({:error, :delete, _, :comment_like}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment_like, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_comment_like({:ok, :delete, :comment_like, repo_data}, conn, allowed_fields) do
    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_comment_like, output_name: "comment_like_info")
  end

  def delete_comment({:error, :edit, :comment, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_comment({:error, :edit, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_comment)
  end

  def delete_comment({:ok, :edit, :comment, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "comment",
      section_id: repo_data.id,
      action: "delete",
      priority: "medium",
      status: "info"
    }, %{user_action: "delete_comment", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_comment, output_name: "comment_info")
  end

  def delete_comment({:error, :edit, _, :comment}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def destroy_comment({:error, :delete, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :destroy_comment)
  end

  def destroy_comment({:ok, :delete, :comment, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "comment",
      section_id: repo_data.id,
      action: "destroy",
      priority: "high",
      status: "info"
    }, %{user_action: "destroy_comment", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :destroy_comment, output_name: "comment_info")
  end

  def destroy_comment({:error, :delete, _, :comment}, conn, _allowed_fields) do
    not_available_record(action: :destroy_comment, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def create_tag({:ok, :add, :blog_tag, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_tag", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_tag, output_name: "tag_info")
  end

  def create_tag({:error, :add, :blog_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_tag)
  end

  def edit_tag({:error, :edit, _, :blog_tag}, conn, _allowed_fields) do
    not_available_record(action: :edit_tag, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def edit_tag({:error, :edit, :blog_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :edit_tag)
  end

  def edit_tag({:ok, :edit, :blog_tag, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag",
      section_id: repo_data.id,
      action: "edit",
      priority: "medium",
      status: "info"
    }, %{user_action: "edit_tag", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :edit_tag, output_name: "tag_info")
  end

  def delete_tag({:error, :delete, _, :blog_tag}, conn, _allowed_fields) do
    not_available_record(action: :delete_tag, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_tag({:error, :delete, :blog_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_tag)
  end

  def delete_tag({:ok, :delete, :blog_tag, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag",
      section_id: repo_data.id,
      action: "delete",
      priority: "medium",
      status: "info"
    }, %{user_action: "delete_tag", cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_tag, output_name: "tag_info")
  end

  def add_tag_to_post({:ok, :add, :blog_tag_mapper, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag_mapper",
      section_id: repo_data.id,
      action: "add",
      priority: "low",
      status: "info"
    }, %{user_action: "add_tag_to_post", post_id: repo_data.post_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :add_tag_to_post, output_name: "post_tag_info")
  end

  def add_tag_to_post({:error, :add, :blog_tag_mapper, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :add_tag_to_post)
  end

  def remove_post_tag({:error, :delete, :blog_tag_mapper, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :remove_post_tag, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def remove_post_tag({:error, :delete, _, :blog_tag_mapper}, conn, _allowed_fields) do
    not_available_record(action: :remove_post_tag, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def remove_post_tag({:error, :delete, :blog_tag_mapper, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :remove_post_tag)
  end

  def remove_post_tag({:ok, :delete, :blog_tag_mapper, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag_mapper",
      section_id: repo_data.id,
      action: "delete",
      priority: "low",
      status: "info"
    }, %{user_action: "remove_post_tag", post_id: repo_data.post_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :remove_post_tag, output_name: "post_tag_info")
  end

  def tags(params, conn, _allowed_fields) do
    json_output(conn, params: params, action: :tags)
  end

  def post_tags(parametr, conn, _allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :post_tags,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      tags: parametr,
    })
  end

  def tag_posts(params, conn, _allowed_fields) do
    json_output(conn, params: params, action: :tag_posts)
  end

  def create_bookmark({:ok, :add, :bookmark, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag_mapper",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_bookmark", section_id: repo_data.section_id, section: repo_data.section, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: repo_data.user_id})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_bookmark, output_name: "bookmark_info")
  end

  def create_bookmark({:error, :add, :bookmark, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_bookmark)
  end

  def delete_bookmark({:ok, :delete, :bookmark, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_tag_mapper",
      section_id: repo_data.id,
      action: "delete",
      priority: "medium",
      status: "info"
    }, %{user_action: "delete_bookmark", section_id: repo_data.section_id, section: repo_data.section, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: repo_data.user_id})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_bookmark, output_name: "bookmark_info")
  end

  def delete_bookmark({:error, :delete, :bookmark, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_bookmark, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_bookmark({:error, :delete, _, :bookmark}, conn, _allowed_fields) do
    not_available_record(action: :delete_bookmark, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_bookmark({:error, :delete, :bookmark, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_bookmark)
  end

  def create_subscription({:error, :add, :subscription, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_subscription)
  end

  def create_subscription({:ok, :add, :subscription, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "subscription",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_subscription", section_id: repo_data.section_id, section: repo_data.section, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: repo_data.user_id})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_subscription, output_name: "subscription_info")
  end

  def delete_subscription({:error, :delete, :subscription, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_subscription, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_subscription({:error, :delete, _, :subscription}, conn, _allowed_fields) do
    not_available_record(action: :delete_subscription, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_subscription({:error, :delete, :subscription, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_subscription)
  end

  def delete_subscription({:ok, :delete, :subscription, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "subscription",
      section_id: repo_data.id,
      action: "delete",
      priority: "medium",
      status: "info"
    }, %{user_action: "delete_subscription", section_id: repo_data.section_id, section: repo_data.section, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: repo_data.user_id})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_subscription, output_name: "subscription_info")
  end

  def create_blog_link({:ok, :add, :blog_link, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_link",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_blog_link", post_id: repo_data.section_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_blog_link, output_name: "blog_link_info")
  end

  def create_blog_link({:error, :add, :blog_link, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_blog_link)
  end

  def edit_blog_link({:ok, :edit, :blog_link, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_link",
      section_id: repo_data.id,
      action: "edit",
      priority: "medium",
      status: "info"
    }, %{user_action: "edit_blog_link", section_id: repo_data.section_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :edit_blog_link, output_name: "blog_link_info")
  end

  def edit_blog_link({:error, :edit, _, :blog_link}, conn, _allowed_fields) do
    not_available_record(action: :edit_blog_link, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def edit_blog_link({:error, :edit, :blog_link, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :edit_blog_link)
  end

  def delete_blog_link({:error, :delete, _, :blog_link}, conn, _allowed_fields) do
    not_available_record(action: :delete_blog_link, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_blog_link({:error, :delete, :blog_link, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_blog_link)
  end

  def delete_blog_link({:ok, :delete, :blog_link, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_link",
      section_id: repo_data.id,
      action: "delete",
      priority: "medium",
      status: "info"
    }, %{user_action: "delete_blog_link", section_id: repo_data.section_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_blog_link, output_name: "blog_link_info")
  end

  def links(params, conn, _allowed_fields) do
    json_output(conn, params: params, action: :links)
  end

  def send_notif({:ok, :add, :notif, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "notif",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "send_notif", section: repo_data.section, section_id: repo_data.section_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :send_notif, output_name: "notif_info")
  end

  def send_notif({:error, :add, :notif, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :send_notif)
  end

  def notifs(params, conn, _allowed_fields) do
    json_output(conn, params: params, action: :notifs)
  end

  def authors(parametr, conn, _allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :authors,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      authors: parametr,
    })
  end

  def create_author({:ok, :add, :blog_author, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_author",
      section_id: repo_data.id,
      action: "add",
      priority: "medium",
      status: "info"
    }, %{user_action: "create_author", post_id: repo_data.post_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :create_author, output_name: "author_info")
  end

  def create_author({:error, :add, :blog_author, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :create_author)
  end

  def delete_author({:error, :delete, :blog_author, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_author, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_author({:error, :delete, _, :blog_author}, conn, _allowed_fields) do
    not_available_record(action: :delete_author, conn: conn, msg: MishkaTranslator.Gettext.dgettext("api_content", "داده مورد نظر وجود ندارد"))
  end

  def delete_author({:error, :delete, :blog_author, repo_error}, conn, _allowed_fields) do
    conn
    |> json_output(repo_error: repo_error, action: :delete_author)
  end

  def delete_author({:ok, :delete, :blog_author, repo_data}, conn, allowed_fields) do
    MishkaContent.General.Activity.create_activity_by_start_child(%{
      type: "internal_api",
      section: "blog_author",
      section_id: repo_data.id,
      action: "delete",
      priority: "medium",
      status: "info"
    }, %{user_action: "delete_author", post_id: repo_data.post_id, cowboy_ip: MishkaApi.cowboy_ip(conn), user_id: Map.get(conn.assigns, :user_id)})

    conn
    |> json_output(repo_data: repo_data, allowed_fields: allowed_fields, action: :delete_author, output_name: "author_info")
  end

  def json_output(conn, repo_data: repo_data, allowed_fields: allowed_fields, action: action, output_name: name) do
    conn
    |> put_status(200)
    |> json(%{
      action: action,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت انجام شد."),
      "#{name}": Map.take(repo_data, allowed_fields)
    })
  end

  def json_output(conn, repo_error: repo_error, action: action) do
    conn
    |> put_status(400)
    |> json(%{
      action: action,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "خطایی در ارسال داده ها پیش آماده است."),
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def json_output(conn, params: params, action: action) do
    conn
    |> put_status(200)
    |> json(%{
      action: action,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "درخواست شما با موفقیت دریافت شد."),
      entries: params.entries,
      page_number: params.page_number,
      page_size: params.page_size,
      total_entries: params.total_entries,
      total_pages: params.total_pages
    })
  end

  defp not_available_record(action: action, conn: conn, msg: msg) do
    conn
    |> put_status(404)
    |> json(%{
      action: action,
      system: @request_error_tag,
      message: MishkaTranslator.Gettext.dgettext("api_content", "رکورد مورد نظر وجود ندارد"),
      errors: %{id: [msg]}
    })
  end
end
