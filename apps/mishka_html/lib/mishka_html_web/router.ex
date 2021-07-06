defmodule MishkaHtmlWeb.Router do
  use MishkaHtmlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MishkaHtmlWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :user_logined do
    plug MishkaHtml.Plug.CurrentTokenPlug
   end

  scope "/", MishkaHtmlWeb do
    pipe_through :browser
    live "/", HomeLive

    live "/blog/:alias_link", BlogsLive

    # need token after login
    # live "/auth/activation", ActivationLive
    # can be a btn instead of a router

    # without login and pass Capcha
    live "/auth/login", LoginLive
    post "/auth/login", AuthController, :login

    live "/auth/reset", ResetPasswordLive
    live "/auth/register", RegisterLive

    get "/auth/log-out", AuthController, :log_out
    # need token after login
    live "/auth/notifications", NotificationsLive
  end

  scope "/", MishkaHtmlWeb do
    pipe_through [:browser, :user_logined]
    live "/blogs", BlogsLive
  end


  scope "/admin", MishkaHtmlWeb do
    pipe_through :browser

    live "/", AdminDashboardLive
    live "/blog-posts", AdminBlogPostsLive
    live "/blog-post", AdminBlogPostLive
    live "/blog-categories", AdminBlogCategoriesLive
    live "/blog-category", AdminBlogCategoryLive
    live "/bookmarks", AdminBookmarksLive
    live "/subscriptions", AdminSubscriptionsLive
    live "/comments", AdminCommentsLive
    live "/comment", AdminCommentLive
    live "/users", AdminUsersLive
    live "/user", AdminUserLive
    live "/logs", AdminLogsLive
    live "/seo", AdminSeoLive
    live "/Subscriptions", AdminSubscriptionsLive
    live "/subscription", AdminSubscriptionLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", MishkaHtmlWeb do
  #   pipe_through :api
  # end

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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MishkaHtmlWeb.Telemetry
    end
  end
end
