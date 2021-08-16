defmodule MishkaHtmlWeb.AdminDashboardLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    if connected?(socket), do: MishkaUser.User.subscribe(); Post.subscribe()
    user_id = Map.get(session, "user_id")
    socket =
      socket
      |> assign(
        page_title: "داشبورد مدیریت",
        body_color: "#a29ac3cf",
        user_id: user_id,
        users: MishkaUser.User.users(conditions: {1, 4}, filters: %{}),
        posts: Post.posts(conditions: {1, 3}, filters: %{}, user_id: user_id)
      )
      {:ok, socket, temporary_assigns: [posts: [], users: []]}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminDashboardLive"})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:user, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        socket
        |> assign(users: MishkaUser.User.users(conditions: {1, 4}, filters: %{}))
       _ ->  socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:post, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        socket
        |> assign(users: Post.posts(conditions: {1, 3}, filters: %{}, user_id: socket.assigns.user_id))
       _ ->  socket
    end

    {:noreply, socket}
  end
end
