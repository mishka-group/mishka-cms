defprotocol MishkaApi.ContentProtocol do
  @fallback_to_any true

  def posts(parametr, conn)

  def post(parametr, conn, type)

  def create_post(parametr, conn, allowed_fields)

  def create_category(parametr, conn, allowed_fields)

  def like_post(parametr, conn)

  def delete_post_like(parametr, conn)

  def edit_post(parametr, conn, allowed_fields)

  def delete_post(parametr, conn, allowed_fields)

  def destroy_post(parametr, conn, allowed_fields)

  def edit_category(parametr, conn, allowed_fields)

  def delete_category(parametr, conn, allowed_fields)

  def destroy_category(parametr, conn, allowed_fields)

  def comment(parametr, conn)

  def comments(parametr, conn)

  def create_comment(parametr, conn)

  def like_comment(parametr, conn)

  def delete_comment_like(parametr, conn)

  def delete_comment(parametr, conn)

  def destroy_comment(parametr, conn)

  def edit_comment(parametr, conn)

  def authors(parametr, conn)

  def create_tag(parametr, conn)

  def edit_tag(parametr, conn)

  def create_bookmark(parametr, conn)

  def delete_bookmark(parametr, conn)

  def create_subscription(parametr, conn)

  def delete_subscription(parametr, conn)

  def add_tag_to_post(parametr, conn)

  def remove_post_tag(parametr, conn)

  def create_blog_link(parametr, conn)

  def edit_blog_link(parametr, conn)

  def delete_blog_link(parametr, conn)

  def links(parametr, conn)

  def send_notif(parametr, conn)

  def notifs(parametr, conn)

  def categories(parametr, conn)

  def category(parametr, conn, allowed_fields)
end

defimpl MishkaApi.ContentProtocol, for: Any do
  use MishkaApiWeb, :controller
  @request_error_tag :content
  alias MishkaContent.General.Comment
  alias MishkaContent.Blog.BlogLink

  def posts(parametr, conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :posts,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      entries: parametr.entries,
      page_number: parametr.page_number,
      page_size: parametr.page_size,
      total_entries: parametr.total_entries,
      total_pages: parametr.total_pages
    })
  end

  def post(nil, conn, _type) do
    not_available_record(action: :post, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def post(parametr, conn, %{type: :comment, comment: comment}) do
    filters =
      Map.take(comment["filters"], Comment.allowed_fields(:string))
      |> MishkaDatabase.convert_string_map_to_atom_map()

    comments = Comment.comments(conditions: {comment["page"], 20}, filters: filters)
    links = BlogLink.links(filters: %{section_id: parametr.id, status: parametr.status})

    conn
    |> put_status(200)
    |> json(%{
      action: :post,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
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
      message: "درخواست شما با موفقیت دریافت شد.",
      post_info: Map.merge(parametr, %{links: links}),
    })
  end

  def create_post({:error, :add, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :create_post,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def create_post({:ok, :add, :post, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :create_post,
      system: @request_error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      post_info: Map.take(repo_data, allowed_fields)
    })
  end

  def edit_post({:error, :edit, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :edit_post,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def edit_post({:ok, :edit, :post, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :edit_post,
      system: @request_error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      post_info: Map.take(repo_data, allowed_fields)
    })
  end

  def edit_post({:error, :edit, _, :post}, conn, _allowed_fields) do
    not_available_record(action: :edit_post, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def delete_post({:error, :edit, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :delete_post,
      system: @request_error_tag,
      message: "رکورد موردنظر با موفقیت تغییر وضعیت داده است. در صورت تایید مدیریت رکورد به صورت کامل حذف خواهد شد.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_post({:ok, :edit, :post, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_post,
      system: @request_error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      post_info: Map.take(repo_data, allowed_fields)
    })
  end

  def delete_post({:error, :edit, _, :post}, conn, _allowed_fields) do
    not_available_record(action: :delete_post, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def destroy_post({:ok, :delete, :post, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :destroy_post,
      system: @request_error_tag,
      message: "رکورد مورد نظر با موفقیت حذف شد.",
      post_info: Map.take(repo_data, allowed_fields)
    })
  end

  def destroy_post({:error, :delete, :post, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :destroy_post,
      system: @request_error_tag,
      message: "رکورد موردنظر با موفقیت تغییر وضعیت داده است. در صورت تایید مدیریت رکورد به صورت کامل حذف خواهد شد.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def destroy_post({:error, :delete, _, :post}, conn, _allowed_fields) do
    not_available_record(action: :destroy_post, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end


  def create_category({:error, :add, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :create_category,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def create_category({:ok, :add, :category, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :create_category,
      system: @request_error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      category_info: Map.take(repo_data, allowed_fields)
    })
  end

  def edit_category({:error, :edit, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :edit_category, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end


  def edit_category({:ok, :edit, :category, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :edit_category,
      system: @request_error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      category_info: Map.take(repo_data, allowed_fields)
    })
  end

  def edit_category({:error, :edit, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :edit_category,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_category({:ok, :edit, :category, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_category,
      system: @request_error_tag,
      message: "رکورد موردنظر با موفقیت تغییر وضعیت داده است. در صورت تایید مدیریت رکورد به صورت کامل حذف خواهد شد..",
      category_info: Map.take(repo_data, allowed_fields)
    })
  end

  def delete_category({:error, :edit, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :delete_category, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def delete_category({:error, :edit, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :delete_category,
      system: @request_error_tag,
      message: "خطایی در حذف رکورد موردنظر پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def destroy_category({:error, :delete, :category, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :destroy_category,
      system: @request_error_tag,
      message: "خطایی در حذف رکورد موردنظر پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def destroy_category({:error, :delete, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :destroy_category, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def destroy_category({:ok, :delete, :category, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :destroy_category,
      system: @request_error_tag,
      message: "رکورد مورد نظر با موفقیت حذف شد.",
      category_info: Map.take(repo_data, allowed_fields)
    })
  end

  def categories(parametr, conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :categories,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      categories: parametr
    })
  end

  def category({:error, _, :category}, conn, _allowed_fields) do
    not_available_record(action: :category, conn: conn, msg: "خطایی در فراخوانی داده مورد نیاز شما پیش آماده است")
  end

  def category({:ok, _, :category, category_info}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :category,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      category_info: Map.take(category_info, allowed_fields)
    })
  end

  def comment(_parametr, _conn) do

  end

  def comments(_parametr, _conn) do

  end

  def create_comment(_parametr, _conn) do

  end

  def like_post(_parametr, _conn) do

  end

  def delete_post_like(_parametr, _conn) do

  end

  def like_comment(_parametr, _conn) do

  end

  def delete_comment_like(_parametr, _conn) do

  end

  def delete_comment(_parametr, _conn) do

  end

  def destroy_comment(_parametr, _conn) do

  end

  def edit_comment(_parametr, _conn) do

  end

  def authors(_parametr, _conn) do

  end

  def create_tag(_parametr, _conn) do

  end

  def edit_tag(_parametr, _conn) do

  end

  def create_bookmark(_parametr, _conn) do

  end

  def delete_bookmark(_parametr, _conn) do

  end

  def create_subscription(_parametr, _conn) do

  end

  def delete_subscription(_parametr, _conn) do

  end

  def add_tag_to_post(_parametr, _connn) do

  end

  def remove_post_tag(_parametr, _connn) do

  end

  def create_blog_link(_parametr, _connn) do

  end

  def edit_blog_link(_parametr, _connn) do

  end

  def delete_blog_link(_parametr, _connn) do

  end

  def links(_parametr, _connn) do

  end

  def send_notif(_parametr, _connn) do

  end

  def notifs(_parametr, _connn) do

  end


  defp not_available_record(action: action, conn: conn, msg: msg) do
    conn
    |> put_status(404)
    |> json(%{
      action: action,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: %{id: [msg]}
    })
  end
end
