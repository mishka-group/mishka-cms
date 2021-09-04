defmodule MishkaHtmlWeb.AdminBlogTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Tag,
      redirect: __MODULE__,
      router: Routes


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
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت برچسب ها"),
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

  # Live CRUD
  paginate(:tags, user_id: false)

  list_search_and_action()

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Tag.delete(id) do
      {:ok, :delete, :blog_tag, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "برچسب: %{title} حذف شده است.", title: MishkaHtml.title_sanitize(repo_data.title))})
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
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین برچسبی وجود ندارد یا ممکن است از قبل حذف شده باشد."))

      {:error, :delete, :blog_tag, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف برچسب اتفاق افتاده است."))
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
