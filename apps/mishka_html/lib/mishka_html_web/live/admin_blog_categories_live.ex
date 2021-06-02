defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_size: 10,
        categories: Category.categories(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  def handle_event("search", params, socket) do
    filters = Map.take(params, Category.allowed_fields(:string))
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()

    new_socket =
      assign(socket,
        [
          categories: Category.categories(conditions: {1, params["count"]}, filters: filters),
          page_size: params["count"]
        ]
      )

    {:noreply, new_socket}
  end

  def handle_params(%{"page" => page}, _url, socket) do
    IO.inspect(socket.assigns.page_size)
    new_socket =
      assign(socket,
        [
          categories: Category.categories(conditions: {page, socket.assigns.page_size}, filters: %{}),
          page_size: socket.assigns.page_size
        ]
      )
    {:noreply, new_socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end
end
