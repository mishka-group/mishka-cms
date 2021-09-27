defmodule MishkaHtmlWeb.AdminBlogPostsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post
  alias MishkaHtmlWeb.Admin.Blog.Post.DeleteErrorComponent
  alias MishkaContent.General.Activity

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Post,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["category_title"]


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_posts_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Post.subscribe(); Activity.subscribe()
    Process.send_after(self(), :menu, 100)
    user_id = Map.get(session, "user_id")
    socket =
      assign(socket,
        page_size: 10,
        user_id: Map.get(session, "user_id"),
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مطالب"),
        body_color: "#a29ac3cf",
        posts: Post.posts(conditions: {1, 10}, filters: %{}, user_id: user_id),
        fpost: Post.posts(conditions: {1, 5}, filters: %{priority: :featured}, user_id: user_id),
        activities: Activity.activities(conditions: {1, 5}, filters: %{section: "blog_post"})
      )
    {:ok, socket, temporary_assigns: [posts: []]}
  end

  # Live CRUD
  paginate(:posts, user_id: true)

  list_search_and_action()

  delete_list_item(:posts, DeleteErrorComponent, true)

  @impl true
  def handle_event("featured_post", %{"id" => id} = _params, socket) do
    socket =
      socket
      |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostLive, id: id))
    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogPostsLive")

  @impl true
  def handle_info({:activity, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        socket
        |> assign(activities: Activity.activities(conditions: {1, 5}, filters: %{section: "blog_post"}))
       _ ->  socket
    end

    {:noreply, socket}
  end

  update_list(:posts, true)

end
