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

  def authors(parametr, conn)

  def create_tag(parametr, conn, allowed_fields)

  def edit_tag(parametr, conn, allowed_fields)

  def delete_tag(parametr, conn, allowed_fields)

  def tags(parametr, conn, allowed_fields)

  def post_tags(parametr, conn, allowed_fields)

  def tag_posts(parametr, conn, allowed_fields)

  def create_bookmark(parametr, conn)

  def delete_bookmark(parametr, conn)

  def create_subscription(parametr, conn)

  def delete_subscription(parametr, conn)

  def add_tag_to_post(parametr, conn, allowed_fields)

  def remove_post_tag(parametr, conn, allowed_fields)

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

  def like_post({:ok, :add, :post_like, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :like_post,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      like_info: Map.take(repo_data, allowed_fields)
    })
  end

  def like_post({:error, :add, :post_like, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :like_post,
      system: @request_error_tag,
      message: "خطایی در پسند کردن پست مورد نظر پیش آماده است",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_post_like({:error, :delete, :post_like, :not_found}, conn, _allowed_fields) do
    conn
    |> put_status(404)
    |> json(%{
      action: :delete_post_like,
      system: @request_error_tag,
      message: "خطایی در پسند کردن پست مورد نظر پیش آماده است",
      errors: :not_found
    })
  end

  def delete_post_like({:ok, :delete, :post_like, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_post_like,
      system: @request_error_tag,
      message: "پسند شما با موفقیت از پست مذکور حذف شد.",
      like_info: Map.take(repo_data, allowed_fields)
    })
  end

  def delete_post_like({:error, :delete, :post_like, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :delete_post_like,
      system: @request_error_tag,
      message: "خطایی در حذف رکورد مورد نظر پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_post_like({:error, :delete, _, :post_like}, conn, _allowed_fields) do
    not_available_record(action: :post_like, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def comment(nil, conn, _allowed_fields) do
    not_available_record(action: :comment, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def comment(parametr, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :comment,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      comment_info: Map.take(parametr, allowed_fields)
    })
  end

  def comments(parametr, conn, _allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :comments,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      entries: parametr.entries,
      page_number: parametr.page_number,
      page_size: parametr.page_size,
      total_entries: parametr.total_entries,
      total_pages: parametr.total_pages
    })
  end

  def create_comment({:error, :add, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :create_comment,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def create_comment({:ok, :add, :comment, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :create_comment,
      system: @request_error_tag,
      message: "نظر شما با موفقیت ذخیره شد.",
      comment_info: Map.take(repo_data, allowed_fields)
    })
  end

  def edit_comment({:ok, :edit, :comment, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :edit_comment,
      system: @request_error_tag,
      message: "نظر شما با موفقیت ذخیره شد.",
      comment_info: Map.take(repo_data, allowed_fields)
    })
  end

  def edit_comment({:error, :edit, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :edit_comment,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def edit_comment({:error, :edit, _, :comment}, conn, _allowed_fields) do
    not_available_record(action: :edit_comment, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def like_comment({:ok, :add, :comment_like, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :like_comment,
      system: @request_error_tag,
      message: "با موفقیت کامنت مورد نظر پسند شد.",
      comment_like_info: Map.take(repo_data, allowed_fields)
    })
  end

  def like_comment({:error, :add, :comment_like, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :like_comment,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_comment_like({:error, :delete, :comment_like, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment_like, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def delete_comment_like({:error, :delete, :comment_like, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :delete_comment_like,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_comment_like({:error, :delete, _, :comment_like}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment_like, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def delete_comment_like({:ok, :delete, :comment_like, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_comment_like,
      system: @request_error_tag,
      message: "پسند شما با موفقیت برداشته شد.",
      comment_like_info: Map.take(repo_data, allowed_fields)
    })
  end

  def delete_comment({:error, :edit, :comment, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def delete_comment({:error, :edit, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :delete_comment,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_comment({:ok, :edit, :comment, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_comment,
      system: @request_error_tag,
      message: "نظر شما با موفقیت ویرایش شد.",
      comment_info: Map.take(repo_data, allowed_fields)
    })
  end

  def delete_comment({:error, :edit, _, :comment}, conn, _allowed_fields) do
    not_available_record(action: :delete_comment, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def destroy_comment({:error, :delete, :comment, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :destroy_comment,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def destroy_comment({:ok, :delete, :comment, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :destroy_comment,
      system: @request_error_tag,
      message: "نظر شما با موفقیت حذف شد.",
      comment_info: Map.take(repo_data, allowed_fields)
    })
  end

  def destroy_comment({:error, :delete, _, :comment}, conn, _allowed_fields) do
    not_available_record(action: :destroy_comment, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def create_tag({:ok, :add, :blog_tag, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :create_tag,
      system: @request_error_tag,
      message: "برچسب مورد نظر با موفقیت ذخیره شد.",
      tag_info: Map.take(repo_data, allowed_fields)
    })
  end

  def create_tag({:error, :add, :blog_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :create_tag,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def edit_tag({:error, :edit, _, :blog_tag}, conn, _allowed_fields) do
    not_available_record(action: :edit_tag, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def edit_tag({:error, :edit, :blog_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :edit_tag,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def edit_tag({:ok, :edit, :blog_tag, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :edit_tag,
      system: @request_error_tag,
      message: "برچسب مورد نظر با موفقیت ویرایش شد.",
      tag_info: Map.take(repo_data, allowed_fields)
    })
  end

  def delete_tag({:error, :delete, _, :blog_tag}, conn, _allowed_fields) do
    not_available_record(action: :delete_tag, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def delete_tag({:error, :delete, :blog_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :delete_tag,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def delete_tag({:ok, :delete, :blog_tag, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_tag,
      system: @request_error_tag,
      message: "برچسب مورد نظر با موفقیت ویرایش شد.",
      tag_info: Map.take(repo_data, allowed_fields)
    })
  end

  def add_tag_to_post({:ok, :add, :blog_tag_mapper, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :add_tag_to_post,
      system: @request_error_tag,
      message: "برچست مورد نظر با موفقیت به پست مذکور تخصیص پیدا کرد.",
      post_tag_info: Map.take(repo_data, allowed_fields)
    })
  end

  def add_tag_to_post({:error, :add, :blog_tag_mapper, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :add_tag_to_post,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def remove_post_tag({:error, :delete, :blog_tag_mapper, :not_found}, conn, _allowed_fields) do
    not_available_record(action: :remove_post_tag, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def remove_post_tag({:error, :delete, _, :blog_tag_mapper}, conn, _allowed_fields) do
    not_available_record(action: :remove_post_tag, conn: conn, msg: "داده مورد نظر وجود ندارد")
  end

  def remove_post_tag({:error, :delete, :blog_tag_mapper, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :remove_post_tag,
      system: @request_error_tag,
      message: "خطایی در ارسال داده ها پیش آماده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def remove_post_tag({:ok, :delete, :blog_tag_mapper, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :remove_post_tag,
      system: @request_error_tag,
      message: "برچست مورد نظر با موفقیت به پست مذکور تخصیص پیدا کرد.",
      post_tag_info: Map.take(repo_data, allowed_fields)
    })
  end

  def tags(parametr, conn, _allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :tags,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      entries: parametr.entries,
      page_number: parametr.page_number,
      page_size: parametr.page_size,
      total_entries: parametr.total_entries,
      total_pages: parametr.total_pages
    })
  end

  def post_tags(parametr, conn, _allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :post_tags,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      tags: parametr,
    })
  end

  def tag_posts(parametr, conn, _allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :tag_posts,
      system: @request_error_tag,
      message: "درخواست شما با موفقیت دریافت شد.",
      entries: parametr.entries,
      page_number: parametr.page_number,
      page_size: parametr.page_size,
      total_entries: parametr.total_entries,
      total_pages: parametr.total_pages
    })
  end

  def create_bookmark(_parametr, _conn) do

  end

  def delete_bookmark(_parametr, _conn) do

  end

  def create_subscription(_parametr, _conn) do

  end

  def delete_subscription(_parametr, _conn) do

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

  def authors(_parametr, _conn) do

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
