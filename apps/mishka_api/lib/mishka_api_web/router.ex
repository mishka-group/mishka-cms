defmodule MishkaApiWeb.Router do
  use MishkaApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MishkaApiWeb do
    pipe_through :api
  end

  pipeline :access_token do
    plug MishkaApi.Plug.AccessTokenPlug
  end

  pipeline :acl_check do
    plug MishkaApi.Plug.AclCheckPlug
  end

  scope "/api/auth/v1", MishkaApiWeb do
    pipe_through [:api, :acl_check]

    # these action need to refresh token
    post "/logout", AuthController, :logout
    post "/refresh-token", AuthController, :refresh_token


    # these action do not need to token check
    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/reset-password", AuthController, :reset_password
    post "/send-delete-tokens-link-by-email", AuthController, :send_delete_tokens_link_by_email
  end

  scope "/api/auth/v1", MishkaApiWeb do
    pipe_through [:api, :access_token, :acl_check]

    post "/delete-tokens", AuthController, :delete_tokens
    post "/delete-token", AuthController, :delete_token
    post "/get-token-expire-time", AuthController, :get_token_expire_time
    post "/user-tokens", AuthController, :user_tokens
    post "/change-password", AuthController, :change_password
    post "/deactive-account", AuthController, :deactive_account
    post "/deactive-account-by-email-link", AuthController, :deactive_account_by_email_link
    post "/edit-profile", AuthController, :edit_profile
    post "/verify-email", AuthController, :verify_email
    post "/verify-email-by-email-link", AuthController, :verify_email_by_email_link
  end

  scope "/api/content/v1", MishkaApiWeb do
    pipe_through [:api, :access_token, :acl_check]

    post "/create-category", ContentController, :create_category
    post "/edit-category", ContentController, :edit_category
    post "/delete-category", ContentController, :delete_category
    post "/destroy-category", ContentController, :destroy_category
    post "/categories", ContentController, :categories
    post "/editor-categories", ContentController, :editor_categories
    post "/category", ContentController, :category


    post "/create-post", ContentController, :create_post
    post "/edit-post", ContentController, :edit_post
    post "/delete-post", ContentController, :delete_post
    post "/destroy-post", ContentController, :destroy_post
    post "/posts", ContentController, :posts
    post "/editor-posts", ContentController, :editor_posts
    post "/post", ContentController, :post
    post "/editor-post", ContentController, :editor_post


    post "/like-post", ContentController, :like_post
    post "/delete-like-post", ContentController, :delete_post_like


    post "/comment", ContentController, :comment
    post "/editor-comment", ContentController, :editor_comment
    post "/comments", ContentController, :comments
    post "/editor-comments", ContentController, :editor_comments
    post "/create-comment", ContentController, :create_comment
    post "/edit-comment", ContentController, :edit_comment
    post "/delete-comment", ContentController, :delete_comment
    post "/destroy-comment", ContentController, :destroy_comment


    post "/like-comment", ContentController, :like_comment
    post "/delete-comment-like", ContentController, :delete_comment_like


    post "/create-tag", ContentController, :create_tag
    post "/edit-tag", ContentController, :edit_tag
    post "/delete-tag", ContentController, :delete_tag
    post "/add-tag-to-post", ContentController, :add_tag_to_post
    post "/remove-post-tag", ContentController, :remove_post_tag
    post "/tags", ContentController, :tags
    post "/tag-posts", ContentController, :tag_posts
    post "/editor-tag-posts", ContentController, :editor_tag_posts
    post "/post-tags", ContentController, :post_tags


    post "/create-bookmark", ContentController, :create_bookmark
    post "/delete-bookmark", ContentController, :delete_bookmark

    post "/create-subscription", ContentController, :create_subscription
    post "/delete-subscription", ContentController, :delete_subscription


    post "/create-blog-link", ContentController, :create_blog_link
    post "/edit-blog-link", ContentController, :edit_blog_link
    post "/delete-blog-link", ContentController, :delete_blog_link
    post "/links", ContentController, :links
    post "/editor-links", ContentController, :editor_links


    post "/notifs", ContentController, :notifs
    post "/editor-notifs", ContentController, :editor_notifs
    post "/send-notif", ContentController, :send_notif


    post "/authors", ContentController, :authors
    post "/create-author", ContentController, :create_author
    post "/delete-author", ContentController, :delete_author

  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MishkaApiWeb.Telemetry
    end
  end
end
