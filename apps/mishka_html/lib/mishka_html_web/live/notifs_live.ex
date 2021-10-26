defmodule MishkaHtmlWeb.NotifsLive do
  use MishkaHtmlWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientNotifView, "notifs_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")

    notifs = MishkaContent.General.Notif.notifs(conditions: {1, 20, :client}, filters: %{
      user_id: user_id,
      target: :all,
      type: :client,
      status: :active
    })

    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "اطلاع رسانی های کاربری"),
        user_id: user_id,
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        page_size: 20,
        page: 1,
        previous_page: false,
        self_pid: self(),
        notifs: notifs.entries
      )
      {:ok, socket, temporary_assigns: [notifs: []]}
  end

  @impl true
  def handle_event("show_notif_navigate", %{"id" => id}, socket) do
    IO.inspect id
    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.NotifsLive", socket.assigns.self_pid})
    {:noreply, socket}
  end

  defp seo_tags(socket) do
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "اطلاع رسانی ها",
      description: "در این بخش می توانید اطلاع رسانی های مربوط به خود را بررسی کنید",
      type: "website",
      keywords: "اطلاع رسانی ها",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end
end
