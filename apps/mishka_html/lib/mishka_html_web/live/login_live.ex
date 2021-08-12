defmodule MishkaHtmlWeb.LoginLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    user_changeset = %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.login_changeset()

    socket =
      assign(socket,
        page_title: "ورود کاربران",
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        trigger_submit: false,
        changeset: user_changeset,
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    changeset = user_changeset(params)
    {:noreply,
     assign(
       socket,
       changeset: changeset,
       trigger_submit: changeset.valid?
     )}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset = user_changeset(params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.LoginLive"})
    {:noreply, socket}
  end

  def user_changeset(params) do
    %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.login_changeset(params)
    |> Map.put(:action, :validation)
  end

  defp seo_tags(socket) do
    # TODO: should change with site address
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "ورود کاربران",
      description: "ورود به سایت تگرگ",
      type: "website",
      keywords: "ورد به سایت",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end
end
