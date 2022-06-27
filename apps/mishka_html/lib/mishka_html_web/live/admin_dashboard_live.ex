defmodule MishkaHtmlWeb.AdminDashboardLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post
  alias MishkaContent.General.Activity

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.Blog.Post,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminDashboardView, "admin_dashboard_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    if connected?(socket), do: MishkaUser.User.subscribe()
    Post.subscribe()
    Activity.subscribe()
    user_id = Map.get(session, "user_id")

    socket =
      socket
      |> assign(
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "داشبورد مدیریت"),
        body_color: "#a29ac3cf",
        user_id: user_id,
        users: MishkaUser.User.users(conditions: {1, 4}, filters: %{}),
        posts: Post.posts(conditions: {1, 3}, filters: %{}, user_id: user_id),
        activities: Activity.activities(conditions: {1, 5}, filters: %{}),
        notifs:
          MishkaContent.General.Notif.notifs(
            conditions: {1, 4},
            filters: %{
              type: :client,
              status: :active
            }
          )
      )

    {:ok, socket, temporary_assigns: [notifs: [], activities: [], posts: [], users: []]}
  end

  selected_menue("MishkaHtmlWeb.AdminDashboardLive")

  @impl true
  def handle_info({:user, :ok, repo_record}, socket) do
    socket =
      case repo_record.__meta__.state do
        :loaded ->
          socket
          |> assign(users: MishkaUser.User.users(conditions: {1, 4}, filters: %{}))

        _ ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:post, :ok, repo_record}, socket) do
    socket =
      case repo_record.__meta__.state do
        :loaded ->
          socket
          |> assign(
            users: Post.posts(conditions: {1, 3}, filters: %{}, user_id: socket.assigns.user_id)
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:activity, :ok, repo_record}, socket) do
    socket =
      case repo_record.__meta__.state do
        :loaded ->
          socket
          |> assign(activities: Activity.activities(conditions: {1, 5}, filters: %{}))

        _ ->
          socket
      end

    {:noreply, socket}
  end
end
