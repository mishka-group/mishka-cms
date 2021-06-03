defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        categories: Category.categories(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  def handle_event("search", params, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: category_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    {:noreply,
      category_assign(socket, params: params["params"], page_size: count, page_number: page)
    }
  end

  def handle_params(%{"page" => page}, _url, socket) do
    {:noreply,
      category_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)
    }
  end

  def handle_params(%{"count" => count} = params, _url, socket) do
    {:noreply,
      category_assign(socket, params: params["params"], page_size: count, page_number: 1)
    }
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
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
          filters: params
        ]
      )
  end
end
