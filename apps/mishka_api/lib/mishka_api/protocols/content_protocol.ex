defprotocol MishkaApi.ContentProtocol do
  @fallback_to_any true

  def posts(parametr, conn)

  def post(parametr, conn)

  def create_post(parametr, conn)

  def create_category(parametr, conn)

  def like_post(parametr, conn)

  def delete_post_like(parametr, conn)

  def edit_post(parametr, conn)

  def delete_post(parametr, conn)

  def destroy_post(parametr, conn)

  def edit_category(parametr, conn)

  def delete_category(parametr, conn)

  def destroy_category(parametr, conn)

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
end

defimpl MishkaApi.ContentProtocol, for: Any do
  use MishkaApiWeb, :controller
  def posts(_parametr, _conn) do

  end

  def post(_parametr, _conn) do

  end

  def post_with_comments(_parametr, _conn) do

  end

  def create_post(_parametr, _conn) do

  end

  def create_category(_parametr, _conn) do

  end

  def like_post(_parametr, _conn) do

  end

  def delete_post_like(_parametr, _conn) do

  end

  def edit_post(_parametr, _conn) do

  end

  def delete_post(_parametr, _conn) do

  end

  def destroy_post(_parametr, _conn) do

  end

  def edit_category(_parametr, _conn) do

  end

  def delete_category(_parametr, _conn) do

  end

  def destroy_category(_parametr, _conn) do

  end

  def comment(_parametr, _conn) do

  end

  def comments(_parametr, _conn) do

  end

  def create_comment(_parametr, _conn) do

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
end
