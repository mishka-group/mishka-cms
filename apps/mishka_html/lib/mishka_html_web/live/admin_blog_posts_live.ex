defmodule MishkaHtmlWeb.AdminBlogPostsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post


  def mount(_params, _session, socket) do
    if connected?(socket) do
      Post.subscribe()
    end

    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: "مدیریت مطالب",
        posts: Post.posts(conditions: {1, 10}, filters: %{}),
        fpost: Post.posts(conditions: {1, 5}, filters: %{priority: :featured}),
      )
    {:ok, socket, temporary_assigns: [posts: []]}
  end

  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    {:noreply,
      post_assign(socket, params: params["params"], page_size: count, page_number: page)
    }
  end

  def handle_params(%{"page" => page}, _url, socket) do
    {:noreply,
      post_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)
    }
  end

  def handle_params(%{"count" => count} = params, _url, socket) do
    {:noreply,
      post_assign(socket, params: params["params"], page_size: count, page_number: 1)
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
            params: post_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    case Post.delete(id) do
      {:ok, :delete, :post, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "مطلب: #{repo_data.title} حذف شده است."})

        socket = post_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

        {:noreply, socket}

      {:error, :delete, :forced_to_delete, :post} ->

        socket =
          socket
          |> assign([
            open_modal: true,
            component: MishkaHtmlWeb.Admin.Blog.Post.DeleteErrorComponent
          ])

        {:noreply, socket}

      {:error, :delete, type, :post} when type in [:uuid, :get_record_by_id] ->

        socket =
          socket
          |> put_flash(:warning, "چنین مطلبی ای وجود ندارد یا ممکن است از قبل حذف شده باشد.")

        {:noreply, socket}

      {:error, :delete, :post, repo_error} ->

        socket =
          socket
          |> put_flash(:error, "خطا در حذف مطلب اتفاق افتاده است.")

        {:noreply, socket}
    end
  end

  def handle_event("featured_post", %{"id" => id} = _params, socket) do
    socket =
      socket
      |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostLive, id: id))
    {:noreply, socket}
  end

  def handle_info({:post, :ok, repo_record}, socket) do
    case repo_record.__meta__.state do
      :loaded ->

        socket = post_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

        {:noreply, socket}

      :deleted -> {:noreply, socket}
       _ ->  {:noreply, socket}
    end
  end

  defp post_filter(params) when is_map(params) do
    Map.take(params, Post.allowed_fields(:string) ++ ["category_title"])
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp post_filter(_params), do: %{}


  defp post_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          posts: Post.posts(conditions: {page, count}, filters: post_filter(params)),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end
end
