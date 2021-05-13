defmodule MishkaApiWeb.Router do
  use MishkaApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MishkaApiWeb do
    pipe_through :api

  end

  scope "/api/auth/v1", MishkaApiWeb do
    pipe_through :api
    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/logout", AuthController, :logout
    post "/refresh-token", AuthController, :refresh_token
    post "/change-password", AuthController, :change_password
    post "/user-tokens", AuthController, :user_tokens
    post "/get-token-expire-time", AuthController, :get_token_expire_time
    post "/reset-password", AuthController, :reset_password
    post "/delete-token", AuthController, :delete_token
    post "/delete-tokens", AuthController, :delete_tokens
    post "/edit-profile", AuthController, :edit_profile
    post "/deactive-account", AuthController, :deactive_account
    post "/deactive-account-by-email-link", AuthController, :deactive_account_by_email_link
    post "/verify-email", AuthController, :verify_email
    post "/verify-email-by-email-link", AuthController, :verify_email_by_email_link
    post "/delete-tokens-by-email-link", AuthController, :delete_tokens_by_email_link
  end


  scope "/api/content/v1", MishkaApiWeb do
    pipe_through :api

    post "/create-category", ContentController, :create_category
    post "/edit-category", ContentController, :edit_category
    post "/delete-category", ContentController, :delete_category
    post "/destroy-category", ContentController, :destroy_category
    post "/categories", ContentController, :categories
    post "/category", ContentController, :category


    post "/create-post", ContentController, :create_post
    post "/edit-post", ContentController, :edit_post
    post "/delete-post", ContentController, :delete_post
    post "/destroy-post", ContentController, :destroy_post
    post "/posts", ContentController, :posts
    post "/post", ContentController, :post
  end


  scope "/api/admin/content/v1", MishkaApiWeb do
    pipe_through :api
    # load admin plug for api

    post "/create-category", AuthController, :AdminContentController
    post "/create-blog", AuthController, :AdminContentController
    post "/blogs", AuthController, :AdminContentController
    post "/categories", AuthController, :AdminContentController
    post "/category", AuthController, :AdminContentController
    post "/edit-blog", AuthController, :AdminContentController
    post "/edit-category", AuthController, :AdminContentController
    post "/delete-blog", AuthController, :AdminContentController
    post "/delete-category", AuthController, :AdminContentController
    post "/delete-categories", AuthController, :AdminContentController
    post "/delete-posts", AuthController, :AdminContentController
    post "/comments", AuthController, :AdminContentController
    post "/comment", AuthController, :AdminContentController
    post "/edit-comment", AuthController, :AdminContentController
    post "/delete-comment", AuthController, :AdminContentController
    post "/delete-comments", AuthController, :AdminContentController
    post "/delete-likes", AuthController, :AdminContentController
    post "/activities", AuthController, :AdminContentController
    post "/delete-activities", AuthController, :AdminContentController
    post "/activity", AuthController, :AdminContentController
    post "/delete-activity", AuthController, :AdminContentController
    post "/edit-activity", AuthController, :AdminContentController
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
