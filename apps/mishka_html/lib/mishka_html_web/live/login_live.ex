defmodule MishkaHtmlWeb.LoginLive do
  use MishkaHtmlWeb, :live_view


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientAuthView, "login_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    user_changeset = %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.login_changeset()

    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "ورود کاربران"),
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        trigger_submit: false,
        changeset: user_changeset,
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    filtered_params = Map.merge(params, %{"email" => MishkaHtml.email_sanitize(params["email"])})
    changeset = user_changeset(filtered_params)
    {:noreply,
     assign(
       socket,
       changeset: changeset,
       trigger_submit: changeset.valid?
     )}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    filtered_params = Map.merge(params, %{"email" => MishkaHtml.email_sanitize(params["email"])})
    changeset = user_changeset(filtered_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
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
