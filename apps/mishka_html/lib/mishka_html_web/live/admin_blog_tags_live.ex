defmodule MishkaHtmlWeb.AdminBlogTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_tags_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Tag.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "مدیریت برچسب ها",
        body_color: "#a29ac3cf",
        filters: %{},
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        tags: Tag.tags(conditions: {1, 10}, filters: %{})
      )

    {:ok, socket, temporary_assigns: [tags: []]}
  end

  @impl true
  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    socket =
      tag_assign(socket, params: params["params"], page_size: count, page_number: page)
    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"page" => page}, _url, socket) do
    socket =
      tag_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)

    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"count" => count} = params, _url, socket) do
    socket =
      tag_assign(socket, params: params["params"], page_size: count, page_number: socket.assigns.page)

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  @impl true
  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: true])}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: false, component: nil])}
  end

  @impl true
  def handle_event("search", params, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: tag_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Tag.delete(id) do
      {:ok, :delete, :blog_tag, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "برچسب: #{MishkaHtml.title_sanitize(repo_data.title)} حذف شده است."})
        socket
        |> tag_assign(params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: socket.assigns.page)

      {:error, :delete, :forced_to_delete, :blog_tag} ->
        socket
        |> assign([
          open_modal: true,
          component: MishkaHtmlWeb.Admin.Tag.DeleteErrorComponent
        ])

      {:error, :delete, type, :blog_tag} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, "چنین برچسبی وجود ندارد یا ممکن است از قبل حذف شده باشد.")

      {:error, :delete, :blog_tag, _repo_error} ->
        socket
        |> put_flash(:error, "خطا در حذف برچسب اتفاق افتاده است.")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:blog_tag, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        tag_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

       _ ->  socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogTagsLive"})
    {:noreply, socket}
  end


  defp tag_filter(params) when is_map(params) do
    Map.take(params, Tag.allowed_fields(:string))
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp tag_filter(_params), do: %{}


  defp tag_assign(socket, params: params, page_size: count, page_number: page) do
      socket
      |> assign(
        [
          filters: params,
          page: page,
          page_size: count,
          tags: Tag.tags(conditions: {page, count}, filters: tag_filter(params))
        ]
      )
  end
end
