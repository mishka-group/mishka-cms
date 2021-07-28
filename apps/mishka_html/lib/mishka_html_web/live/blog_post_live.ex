defmodule MishkaHtmlWeb.BlogPostLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.{Category, Post}
  # TODO: done // fix htmlUI of comment
  # TODO: done // show post
  # TODO: it's comments with pagination after 2 sec
  # TODO: create params for paginate comments, top and bot
  # TODO: check if it dosent jump to top, search how to jump to top
  # TODO: done // show users who are auther, html and db code select
  # TODO: count post likes and if user liked or not subquery
  # TODO: sharing to social media sites
  # TODO: we need to input seo tags
  # TODO: Tags, likes
  # TODO: we need to input seo tags
  # TODO: show Options of a post on page
  # TODO: show map and implement map's SEO tag and header tag
  # TODO: create AMP page
  # TODO: create Print page
  # TODO: add subscription for user
  # TODO: show coustom title in post and header
  # TODO: show unpublish time if exists and counter
  # TODO: create reporting popup and db for administartor or editor
  # TODO: show hits and update it
  # TODO: show post links with a html box
  # TODO: show priority on post
  # TODO: show short link to share, this should be event base if exist load on db and copy on clipboard if not create
  # TODO: make bookmarks for users who are logined
  # TODO: Create user profile picture after creating media manager


  @impl true
  def mount(%{"alias_link" => alias_link}, session, socket) do
    socket = case Post.post(alias_link, "active") do
      nil ->
        socket =
          socket
          |> put_flash(:info, "چنین محتوایی وجود ندارد")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))

        {:ok, socket}
      post ->
        if connected?(socket) do
          Post.subscribe()
        end

        Process.send_after(self(), :menu, 100)
        socket =
          assign(socket,
            page_title: "بلاگ",
            body_color: "#40485d",
            user_id: Map.get(session, "user_id"),
            post: post,
          )

        {:ok, socket, temporary_assigns: [posts: [], categories: [], featured_posts: []]}
    end

    socket
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.BlogPostLive"})
    {:noreply, socket}
  end
end
