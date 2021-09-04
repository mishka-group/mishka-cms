defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Category,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_categories_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Category.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        body_color: "#a29ac3cf",
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مجموعه ها"),
        categories: Category.categories(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  # Live CRUD
  paginate(:categories, user_id: false)

  list_search_and_action()

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Category.delete(id) do
      {:ok, :delete, :category, repo_data} ->
        Notif.notify_subscribers(%{
          id: repo_data.id,
          msg: MishkaTranslator.Gettext.dgettext("html_live", "مجموعه: %{title} حذف شده است.", title: MishkaHtml.title_sanitize(repo_data.title))
          }
        )
        category_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

      {:error, :delete, :forced_to_delete, :category} ->

        socket
        |> assign([
          open_modal: true,
          component: MishkaHtmlWeb.Admin.Blog.Category.DeleteErrorComponent
        ])

      {:error, :delete, type, :category} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین مجموعه ای وجود ندارد یا ممکن است از قبل حذف شده باشد."))

      {:error, :delete, :category, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف مجموعه اتفاق افتاده است."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:category, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        category_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

       _ ->  socket
    end

    {:noreply, socket}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogCategoriesLive"})
    {:noreply, socket}
  end

  defp category_filter(params) when is_map(params) do
    Map.take(params, Category.allowed_fields(:string))
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp category_filter(_params), do: %{}

  defp category_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          categories: Category.categories(conditions: {page, count}, filters: category_filter(params)),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end
end
