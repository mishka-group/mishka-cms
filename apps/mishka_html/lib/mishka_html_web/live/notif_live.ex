defmodule MishkaHtmlWeb.NotifLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientNotifView, "notif_live.html", assigns)
  end

  @impl true
  def mount(%{"id" => notif_id}, session, socket) do
    socket = case Notif.notif(notif_id, Map.get(session, "user_id")) do
      nil ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین صفحه ای وجود ندارد یا از قبل حذف یا شما به آن دسترسی ندارید."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.NotifsLive))

      record ->
        Process.send_after(self(), :menu, 100)
        socket
        |> assign(
          page_title: MishkaTranslator.Gettext.dgettext("html_live", "اطلاع رسانی"),
          body_color: "#40485d",
          seo_tags: seo_tags(socket, notif_id),
          trigger_submit: false,
          user_id: Map.get(session, "user_id"),
          self_pid: self(),
          notif: record
        )
    end

    {:ok, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.NotifLive", socket.assigns.self_pid})
    {:noreply, socket}
  end

  defp seo_tags(socket, notif_id) do
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "اطلاع رسانی",
      description: "در این بخش می توانید یک اطلاع رسانی خاص را مورد بررسی قرار بدهید",
      type: "website",
      keywords: "اطلاع رسانی",
      link: site_link <> Routes.live_path(socket, __MODULE__, notif_id)
    }
  end
end
