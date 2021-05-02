defmodule MishkaApiWeb.ContentController do
  use MishkaApiWeb, :controller

  # add ip limitter and os info
  # handel cache of contents

  def posts(_conn, %{"category_id" => _category_id, "page" => _page}) do
    # action blogs:view
    # list of categories
  end

  def posts(_conn, %{"page" => _page}) do
    # action blogs:view
    # list of categories
  end

  def post(_conn, %{"post_id" => _post_id}) do
    # action blogs:view
    # list of categories
  end

  def post_with_comments(_conn, %{"post_id" => _post_id, "page" => _page}) do
    # action blogs:view
    # list of categories
  end

  def create_post(_conn, _params) do
    # action blogs:edit
    # action blogs:create
  end

  def create_category(_conn, _params) do
    # action blogs:edit
  end

  def like_post(_conn, %{"post_id" => _post_id}) do
    # action blogs:view
  end

  def delete_post_like(_conn, %{"post_id" => _post_id}) do
    # action blogs:user_id:view
  end

  def edit_post(_conn, %{"post_id" => _post_id} = _params) do
    # action blogs:edit
  end

  def delete_post(_conn, %{"post_id" => _post_id}) do
    # action blogs:edit
    # change flag of status
  end

  def destroy_post(_conn, %{"post_id" => _post_id}) do
    # action blogs:*
  end

  def edit_category(_conn, %{"category_id" => _category_id} = _params) do
    # action blogs:edit
  end

  def delete_category(_conn, %{"category_id" => _category_id}) do
    # action blogs:edit
    # change flag of status
  end

  def destroy_category(_conn, %{"category_id" => _category_id}) do
    # action *
  end

  def comment(_conn, %{"comment_id" => _comment_id}) do
    # action blogs:view
  end

  def comments(_conn, %{"section" => _section, "page" => _page}) do
    # action blogs:edit
  end

  def comments(_conn, %{"page" => _page}) do
    # action blogs:edit
  end

  def comments(_conn, %{"section_id" => _section_id}) do
    # action blogs:view
  end

  def create_comment(_conn, %{"section_id" => _section_id, "description" => _description, "sub" => _sup
  }) do
    # action blogs:view
  end

  def create_comment(_conn, %{"section_id" => _section_id, "description" => _description
  }) do
    # action blogs:view
  end

  def like_comment(_conn, %{"comment_id" => _comment_id}) do
    # action *:view
  end

  def delete_comment_like(_conn, %{"comment_id" => _comment_id}) do
    # action blogs:user_id:view
  end

  def delete_comment(_conn, %{"comment_id" => _comment_id}) do
    # action blog:edit
    # change flag of status
  end

  def destroy_comment(_conn, %{"comment_id" => _comment_id}) do
    # action *
  end

  def edit_comment(_conn, %{"comment_id" => _comment_id, "description" => _description}) do
    # action blog:edit
  end

  def author(_conn, _params) do
    # action blog:create
  end

  def create_tag(_conn, _params) do
     # action blog:create
  end

  def edit_tag(_conn, _params) do
    # action blog:edit
  end

  def create_bookmark(_conn, _params) do
    # action blog:view
  end

  def delete_bookmark(_conn, _params) do
    # action blog:user_id:view
  end

  def create_subscription(_conn, _params) do
    # action blog:view
  end

  def delete_subscription(_conn, _params) do
    # action blog:user_id:view
  end
end
