defmodule MishkaUser.Acl.Action do

  @spec actions :: map()
  def actions() do
    %{
      # client router
      # "Elixir.MishkaHtmlWeb.BlogsLive" => "admin:*",


      # admin router
      "MishkaHtmlWeb.AdminDashboardLive" => "admin:*" ,
      "MishkaHtmlWeb.AdminBlogPostsLive" => "admin:edit" ,
      "MishkaHtmlWeb.AdminBlogPostLive" => "admin:edit" ,
      "MishkaHtmlWeb.AdminBlogCategoriesLive" => "admin:edit" ,
      "MishkaHtmlWeb.AdminBlogCategoryLive" => "admin:edit" ,
      "MishkaHtmlWeb.AdminBookmarksLive" => "*" ,
      "MishkaHtmlWeb.AdminSubscriptionsLive" => "*" ,
      "MishkaHtmlWeb.AdminSubscriptionLive" => "*" ,
      "MishkaHtmlWeb.AdminCommentsLive" => "admin:edit" ,
      "MishkaHtmlWeb.AdminCommentLive" => "admin:edit" ,
      "MishkaHtmlWeb.AdminUsersLive" => "*" ,
      "MishkaHtmlWeb.AdminUserLive" => "*" ,
      "MishkaHtmlWeb.AdminLogsLive" => "*" ,
      "MishkaHtmlWeb.AdminSeoLive" => "*" ,
      "MishkaHtmlWeb.AdminBlogPostAuthorsLive" => "admin:edit",
      "MishkaHtmlWeb.AdminBlogNotifLive" => "*",
      "MishkaHtmlWeb.AdminBlogNotifsLive" => "*"
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
