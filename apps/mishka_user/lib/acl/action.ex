defmodule MishkaUser.Acl.Action do

  def actions() do
    %{
      # client router
      # admin router
      "Elixir.MishkaHtmlWeb.AdminDashboardLive" => "*" ,
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


end
