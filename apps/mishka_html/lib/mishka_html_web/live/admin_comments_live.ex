defmodule MishkaHtmlWeb.AdminCommentsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Comment
  alias MishkaHtmlWeb.Admin.Blog.Category.DeleteErrorComponent

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

  delete_list_item(:comments, DeleteErrorComponent, true)

  @impl true
  def handle_event("dependency", %{"id" => id}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: MishkaHtml.Helpers.LiveCRUD.paginate_assign_filter(Map.merge(socket.assigns.filters, %{"sub" => id}), Comment, nil),
            count: socket.assigns.page_size,
          )
      )
    {:noreply, socket}
  end

  update_list(:comments, true)

  selected_menue("MishkaHtmlWeb.AdminCommentsLive")
end
