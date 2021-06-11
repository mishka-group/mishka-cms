defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  def mount(_params, _session, socket) do
    if connected?(socket) do
      MishkaContent.Blog.Category.subscribe()
    end

    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: "مدیریت مجموعه ها",
        categories: Category.categories(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
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

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
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

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: true])}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: false, component: nil])}
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    case Category.delete(id) do
      {:ok, :delete, :category, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "مجموعه: #{repo_data.title} حذف شده است."})

        socket = category_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

        {:noreply, socket}

      {:error, :delete, :forced_to_delete, :category} ->

        socket =
          socket
          |> assign([
            open_modal: true,
            component: MishkaHtmlWeb.Admin.Blog.ErrorCategoryDeleteComponent
          ])

        {:noreply, socket}

      {:error, :delete, type, :category} when type in [:uuid, :get_record_by_id] ->

        socket =
          socket
          |> put_flash(:warning, "چنین مجموعه ای وجود ندارد یا ممکن است از قبل حذف شده باشد.")

        {:noreply, socket}

      {:error, :delete, :category, repo_error} ->

        socket =
          socket
          |> put_flash(:error, "خطا در حذف مجموعه اتفاق افتاده است.")

        {:noreply, socket}
    end
  end

  def handle_info({:category, :ok, repo_record}, socket) do
    IO.inspect(repo_record.__meta__.state)
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
