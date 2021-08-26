defmodule MishkaUser.Acl.Action do

  @spec actions :: map()
  def actions() do
    %{
      # client router
      # "Elixir.MishkaHtmlWeb.BlogsLive" => "admin:*",


      # admin router
      "Elixir.MishkaHtmlWeb.AdminDashboardLive" => "admin:*" ,
      "Elixir.MishkaHtmlWeb.AdminBlogPostsLive" => "admin:edit" ,
      "Elixir.MishkaHtmlWeb.AdminBlogPostLive" => "admin:edit" ,
      "Elixir.MishkaHtmlWeb.AdminBlogCategoriesLive" => "admin:edit" ,
      "Elixir.MishkaHtmlWeb.AdminBlogCategoryLive" => "admin:edit" ,
      "Elixir.MishkaHtmlWeb.AdminBookmarksLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminSubscriptionsLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminSubscriptionLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminCommentsLive" => "admin:edit" ,
      "Elixir.MishkaHtmlWeb.AdminCommentLive" => "admin:edit" ,
      "Elixir.MishkaHtmlWeb.AdminUsersLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminUserLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminLogsLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminSeoLive" => "*" ,
      "Elixir.MishkaHtmlWeb.AdminBlogPostAuthorsLive" => "admin:edit"
    }
  end

  @spec actions(:api) :: map()
  def actions(:api) do
    %{

      "api/content/v1/editor-posts/" => "blog:edit",
      "api/content/v1/editor-post/" => "blog:edit",
      "api/content/v1/editor-categories/" => "blog:edit",
      "api/content/v1/editor-comment/" => "blog:edit",
      "api/content/v1/editor-comments/" => "blog:edit",
      "api/content/v1/category/" => "blog:edit",
      "api/content/v1/edit-comment/" => "blog:edit",
      "api/content/v1/delete-comment/" => "blog:edit",
      "api/content/v1/destroy-comment/" => "admin:edit",
      "api/content/v1/create-tag/" => "admin:edit",
      "api/content/v1/edit-tag/" => "admin:edit",
      "api/content/v1/delete-tag/" => "admin:edit",
      "api/content/v1/add-tag-to-post/" => "blog:edit",
      "api/content/v1/remove-post-tag/" => "blog:edit",
      "api/content/v1/editor-tag-posts/" => "blog:edit",
      "api/content/v1/create-blog-link/" => "blog:edit",
      "api/content/v1/edit-blog-link/" => "blog:edit",
      "api/content/v1/delete-blog-link/" => "blog:edit",
      "api/content/v1/editor-links/" => "blog:edit",
      "api/content/v1/editor-notifs/" => "blog:edit",
      "api/content/v1/send-notif/" => "*",
      "api/content/v1/create-author/" => "blog:edit",
      "api/content/v1/delete-author/" => "blog:edit",


      "api/content/v1/create-category/" => "admin:edit",
      "api/content/v1/edit-category/" => "admin:edit",
      "api/content/v1/delete-category/" => "admin:edit",
      "api/content/v1/destroy-category/" => "admin:edit",
      "api/content/v1/create-post/" => "blog:edit",
      "api/content/v1/edit-post/" => "blog:edit",
      "api/content/v1/delete-post/" => "admin:edit",
      "api/content/v1/destroy-post/" => "admin:edit",
    }
  end

end
