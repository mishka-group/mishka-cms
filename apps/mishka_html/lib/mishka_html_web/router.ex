defmodule MishkaHtmlWeb.Router do
  use MishkaHtmlWeb, :router
  use Plug.ErrorHandler


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
    live "/blog/tags", HomeLive
    live "/blog/tag", HomeLive
  end

  scope "/", MishkaHtmlWeb do
    pipe_through :browser

    get "/auth/verify-email/:code", AuthController, :verify_email
    get "/auth/deactive-account/:code", AuthController, :deactive_account
    get "/auth/delete-tokens/:code", AuthController, :delete_tokens
  end

  scope "/", MishkaHtmlWeb do
    pipe_through [:browser, :not_login]

    # without login and pass Capcha
    live "/auth/login", LoginLive
    post "/auth/login", AuthController, :login
    live "/auth/reset/:random_link", ResetPasswordLive
    live "/auth/reset", ResetPasswordLive
    live "/auth/register", RegisterLive
    live "/auth/reset-change-password/:random_link", ResetChangePasswordLive
  end

  scope "/", MishkaHtmlWeb do
    pipe_through [:browser, :user_logined]

    get "/auth/log-out", AuthController, :log_out
    live "/auth/notifications", NotificationsLive
  end

  scope "/user", MishkaHtmlWeb do
    pipe_through [:browser, :user_logined]

    live "/bookmarks", BookmarksLive
  end


  scope "/admin", MishkaHtmlWeb do
    pipe_through [:browser, :user_logined]

    live "/", AdminDashboardLive
    live "/blog-posts", AdminBlogPostsLive
    live "/blog-post", AdminBlogPostLive
    live "/blog-categories", AdminBlogCategoriesLive
    live "/blog-category", AdminBlogCategoryLive
    live "/blog-tags", AdminBlogTagsLive
    live "/blog-tag", AdminBlogTagLive
    live "/blog-post-tags/:id", AdminBlogPostTagsLive
    live "/blog-links/:id", AdminLinksLive
    live "/blog-link/:post_id", AdminLinkLive
    live "/bookmarks", AdminBookmarksLive
    live "/subscriptions", AdminSubscriptionsLive
    live "/subscription", AdminSubscriptionLive
    live "/comments", AdminCommentsLive
    live "/comment", AdminCommentLive
    live "/users", AdminUsersLive
    live "/user", AdminUserLive
    live "/activities", AdminActivitiesLive
    live "/activity/:id", AdminActivityLive
    live "/seo", AdminSeoLive
    live "/roles", AdminUserRolesLive
    live "/role", AdminUserRoleLive
    live "/role-permissions", AdminUserRolePermissionsLive
    live "/blog-authors/:post_id", AdminBlogPostAuthorsLive
    live "/settings", AdminSettingsLive
    live "/setting", AdminSettingLive
    live "/notifs", AdminBlogNotifsLive
    live "/notif", AdminBlogNotifLive
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
    if !is_nil(Map.get(reason, :conn)), do:
        MishkaContent.General.Activity.router_catch(conn, kind, reason)
  after
    conn
  end

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
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
