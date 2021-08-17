defmodule MishkaHtmlWeb.AdminCommentsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Comment

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminCommentView, "admin_comments_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Comment.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: "مدیریت نظرات",
        body_color: "#a29ac3cf",
        comments: Comment.comments(conditions: {1, 10}, filters: %{}, user_id: nil)
      )
    {:ok, socket, temporary_assigns: [comments: []]}
  end

  @impl true
  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    {:noreply,
      comment_assign(socket, params: params["params"], page_size: count, page_number: page)
    }
  end

  @impl true
  def handle_params(%{"page" => page}, _url, socket) do
    {:noreply,
      comment_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)
    }
  end

  @impl true
  def handle_params(%{"count" => count} = params, _url, socket) do
    {:noreply,
      comment_assign(socket, params: params["params"], page_size: count, page_number: 1)
    }
  end

  @impl true
  def handle_params(%{"section_id" => _section_id} = params, _url, socket) do
    {:noreply,
      comment_assign(socket, params: params, page_size: socket.assigns.page_size, page_number: 1)
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", params, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: comment_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("dependency", %{"id" => id}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: comment_filter(Map.merge(socket.assigns.filters, %{"sub" => id})),
            count: socket.assigns.page_size,
          )
      )
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
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Comment.delete(id) do
      {:ok, :delete, :comment, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "از لیست یک نظر حذف شد."})
        comment_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

      {:error, :delete, :forced_to_delete, :comment} ->
        socket
        |> assign([
          open_modal: true,
          component: MishkaHtmlWeb.Admin.Blog.Category.DeleteErrorComponent
        ])

      {:error, :delete, type, :comment} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد.")

      {:error, :delete, :comment, _repo_error} ->
        socket
        |> put_flash(:error, "خطا در حذف نظر اتفاق افتاده است.")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:comment, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        comment_assign(
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
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminCommentsLive"})
    {:noreply, socket}
  end

  defp comment_filter(params) when is_map(params) do
    Map.take(params, Comment.allowed_fields(:string))
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp comment_filter(_params), do: %{}

  defp comment_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          comments: Comment.comments(conditions: {page, count}, filters: comment_filter(params), user_id: nil),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end
end
