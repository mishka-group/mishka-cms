defmodule MishkaHtmlWeb.AdminCommentsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Comment

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Comment,
      redirect: __MODULE__,
      router: Routes


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
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت نظرات"),
        body_color: "#a29ac3cf",
        comments: Comment.comments(conditions: {1, 10}, filters: %{}, user_id: nil)
      )
    {:ok, socket, temporary_assigns: [comments: []]}
  end

  # Live CRUD
  paginate(:comments, user_id: true)

  list_search_and_action()

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
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Comment.delete(id) do
      {:ok, :delete, :comment, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "از لیست یک نظر حذف شد.")})
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
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد."))

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
