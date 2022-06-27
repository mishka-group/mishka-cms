defmodule MishkaHtmlWeb.AdminActivityLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Activity

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.Blog.BlogLink,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminActivityView, "admin_activity_live.html", assigns)
  end

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket =
      case Activity.show_by_id(id) do
        {:error, :get_record_by_id, _error_atom} ->
          socket
          |> put_flash(
            :warning,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "چنین لاگی وجود ندارد یا ممکن است از قبل حذف شده باشد."
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminActivitiesLive))

        {:ok, :get_record_by_id, _error_atom, record} ->
          Process.send_after(self(), :menu, 100)

          socket
          |> assign(
            activity: record,
            user_id: Map.get(session, "user_id"),
            body_color: "#a29ac3cf"
          )
      end

    {:ok, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminLogLive")
end
