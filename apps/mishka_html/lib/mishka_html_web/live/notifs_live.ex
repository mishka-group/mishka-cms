defmodule MishkaHtmlWeb.NotifsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif
  alias MishkaContent.General.UserNotifStatus

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientNotifView, "notifs_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    Notif.subscribe()

    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "اطلاع رسانی های کاربری"),
        user_id: user_id,
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        page: 1,
        filters: %{},
        previous_page: false,
        self_pid: self(),
        notifs: Notif.notifs(conditions: {1, 20, :client}, filters: %{user_id: user_id, target: :all, type: :client, status: :active})
      )
      {:ok, socket, temporary_assigns: [notifs: []]}
  end

  @impl true
  def handle_params(%{"page" => page} = _params, _url, socket) do
    socket =
      socket
      |> assign(
        notifs: Notif.notifs(conditions: {page, 20, :client}, filters: %{user_id: socket.assigns.user_id, target: :all, type: :client, status: :active}),
        page: page
      )
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("show_notif_navigate", %{"id" => id}, socket) do
    notif =
      Notif.notifs(conditions: {1, 1, :client}, filters: %{id: id, user_id: socket.assigns.user_id, target: :all, type: :client, status: :active})
    {:noreply, notif_link(socket, notif, socket.assigns.user_id)}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.NotifsLive", socket.assigns.self_pid})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:notif, :ok, repo_record}, socket) do
    socket = if repo_record.user_id == socket.assigns.user_id or is_nil(repo_record.user_id) do
      update(socket, :notifs, fn _notif ->
        socket
        |> assign(notifs: Notif.notifs(conditions: {socket.assigns.page, 20, :client}, filters: %{user_id: socket.assigns.user_id, target: :all, type: :client, status: :active}))
      end)
    else
      socket
    end

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


  def notif_link(socket, notif, user_id) do
    socket =
      with {:notification, true, notif_entry} <- {:notification, length(notif.entries) == 1, notif.entries},
           {:notif_section, true, _section, _notif_info} <- {:notif_section, List.first(notif_entry).section in [:user_only, :public], List.first(notif_entry).section, notif_entry} do

        record = List.first(notif_entry)
        if is_nil(record.user_notif_status.status_type) do
          UserNotifStatus.create(%{type: :read, notif_id: record.id, user_id: user_id})
        end

        socket
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.NotifLive, List.first(notif_entry).id))

      else
        {:notification, false, []} ->
          socket
          |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین صفحه ای وجود ندارد یا از قبل حذف شده است."))
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.NotifsLive))

        {:notif_section, false, :blog_post, notif_info} ->
          socket = case MishkaContent.Blog.Post.show_by_id(List.first(notif_info).section_id) do
            {:ok, :get_record_by_id, _error_tag, repo_data} ->

              record = List.first(notif.entries)
              if is_nil(record.user_notif_status.status_type) do
                UserNotifStatus.create(%{type: :read, notif_id: record.id, user_id: user_id})
              end

              socket
              |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogPostLive, repo_data.alias_link))

            _ ->
              socket
              |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "چنین محتوایی وجود ندارد یا از قبل حذف شده است."))
              |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))
          end

          socket

        {:notif_section, false, :admin, notif_info} ->

          socket
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifLive, id: List.first(notif_info).id, type: "show"))
      end

      socket
  end
  def notif_read_status(status) do
    case status do
      nil -> MishkaTranslator.Gettext.dgettext("html_live", "خوانده نشده")
      :read -> MishkaTranslator.Gettext.dgettext("html_live", "خوانده شده")
      _ -> MishkaTranslator.Gettext.dgettext("html_live", "ندید گرفته شده")
    end
  end

  def notif_section(section) do
    case section do
      :blog_post -> MishkaTranslator.Gettext.dgettext("html_live", "مطلب بلاگ")
      :admin -> MishkaTranslator.Gettext.dgettext("html_live", "مدیریتی")
      :user_only -> MishkaTranslator.Gettext.dgettext("html_live", "مختص به شما")
      :public -> MishkaTranslator.Gettext.dgettext("html_live", "ارسال همگانی")
    end
  end

  def notif_type(type) do
    case type do
      :client -> MishkaTranslator.Gettext.dgettext("html_live", "نوع کاربری")
      :admin -> MishkaTranslator.Gettext.dgettext("html_live", "نوع مدیریتی")
    end
  end
end
