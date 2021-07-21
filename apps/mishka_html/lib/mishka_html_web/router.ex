defmodule MishkaHtmlWeb.Router do
  use MishkaHtmlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MishkaHtmlWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MishkaHtml.Plug.AclCheckPlug
  end

  pipeline :user_logined do
    plug MishkaHtml.Plug.CurrentTokenPlug
  end

  pipeline :not_login do
    plug MishkaHtml.Plug.NotLoginPlug
  end

  scope "/", MishkaHtmlWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/blogs", BlogsLive
    live "/blog/category/:alias_link", BlogCategoryLive
    live "/blog/:alias_link", BlogPostLive
    live "/blog/tags", BlogPostLive
    live "/blog/tag", BlogPostLive
  end

  scope "/", MishkaHtmlWeb do
    pipe_through [:browser, :not_login]

    # without login and pass Capcha
    live "/auth/login", LoginLive
    post "/auth/login", AuthController, :login
    live "/auth/reset", ResetPasswordLive
    live "/auth/register", RegisterLive
  end

  scope "/", MishkaHtmlWeb do
    pipe_through [:browser, :user_logined]

    get "/auth/log-out", AuthController, :log_out
    live "/auth/notifications", NotificationsLive
  end


  scope "/admin", MishkaHtmlWeb do
    pipe_through [:browser, :user_logined]

    live "/", AdminDashboardLive
    live "/blog-posts", AdminBlogPostsLive
    live "/blog-post", AdminBlogPostLive
    live "/blog-categories", AdminBlogCategoriesLive
    live "/blog-category", AdminBlogCategoryLive
    live "/bookmarks", AdminBookmarksLive
    live "/subscriptions", AdminSubscriptionsLive
    live "/subscription", AdminSubscriptionLive
    live "/comments", AdminCommentsLive
    live "/comment", AdminCommentLive
    live "/users", AdminUsersLive
    live "/user", AdminUserLive
    live "/logs", AdminLogsLive
    live "/seo", AdminSeoLive
    live "/roles", AdminUserRolesLive
    live "/role", AdminUserRoleLive
    live "/role-permissions", AdminUserRolePermissionsLive
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
      pipe_through [:browser, :user_logined]
      live_dashboard "/dashboard", metrics: MishkaHtmlWeb.Telemetry
    end
  end
end
