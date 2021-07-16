defmodule MishkaUser.Acl.Action do

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
    }
  end

  def actions(:api) do
    %{
      # client router


      # admin router
      "api/content/v1/create-category/" => "admin:edit",
      "api/content/v1/edit-category/" => "admin:edit",
      "api/content/v1/delete-category/" => "admin:edit",
      "api/content/v1/destroy-category/" => "admin:edit",
      "api/content/v1/create-post/" => "admin:edit",
      "api/content/v1/edit-post/" => "admin:edit",
      "api/content/v1/delete-post/" => "admin:edit",
      "api/content/v1/destroy-post/" => "admin:edit",
    }
  end

end
