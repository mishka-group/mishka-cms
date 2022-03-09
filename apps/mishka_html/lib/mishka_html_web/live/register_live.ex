defmodule MishkaHtmlWeb.RegisterLive do
  use MishkaHtmlWeb, :live_view
  @allowed_fields_output ["full_name", "username", "email", "status", "id"]
  @allowed_fields ["full_name", "email", "password", "username", "unconfirmed_email"]
  alias MishkaHtmlWeb.Router.Helpers

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientAuthView, "register_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    changeset = %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.changeset()

    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "ثبت نام کاربر"),
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        changeset: changeset,
        user_id: Map.get(session, "user_id"),
        self_pid: self(),
        user_ip: get_connect_info(socket, :peer_data).address
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    {token, filtered_params} = get_google_recaptcha_and_filtered_params(params)

    socket =
      with {:ok, :verify, _token_info} <- MishkaUser.Validation.GoogleRecaptcha.verify(token),
           {:ok, :add, _error_tag, repo_data} <- MishkaUser.User.create(filtered_params, @allowed_fields) do

        allowed_user_info = Map.take(repo_data, @allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
        MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})
        state = %MishkaInstaller.Reference.OnUserAfterSave{
          user_info: allowed_user_info, ip: socket.assigns.user_ip, endpoint: :html, status: :added, conn: socket, modifier_user: :self,
          extra: %{site_url: Helpers.url(socket), endpoint_uri: Helpers.auth_path(socket, :verify_email, "random_link")}
        }
        MishkaInstaller.Hook.call(event: "on_user_after_save", state: state).conn
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "ثبت نام شما موفقیت آمیز بوده است و هم اکنون می توانید وارد سایت شوید. لطفا برای دسترسی کامل به سایت حساب کاربر خود را فعال کنید. برای فعال سازی لطفا به ایمیل خود سر زده و روی لینک یا کد فعال سازی که برای شما ارسال گردیده است کلیک کنید."))
        |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.LoginLive))

      else
        {:error, :add, error_tag, changeset} ->
          on_user_after_save_failure({:error, :add, error_tag, changeset}, socket.assigns.user_ip, socket).conn
          |> assign(changeset: changeset)

        {:error, :verify, msg} ->
          on_user_after_save_failure({:error, :verify, msg}, socket.assigns.user_ip, socket).conn
          |> put_flash(:error, msg)
          |> push_event("update_recaptcha", %{client_side_code: System.get_env("CAPTCHA_CLIENT_SIDE_CODE")})
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do

    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })

    changeset = user_changeset(filtered_params)

    socket =
      if(changeset.valid?, do: push_event(socket, "update_recaptcha", %{client_side_code: System.get_env("CAPTCHA_CLIENT_SIDE_CODE")}), else: socket)
      |> assign(changeset: changeset)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.RegisterLive", socket.assigns.self_pid})
    {:noreply, socket}
  end

  @impl true
  def handle_info(_params, socket) do
    {:noreply, socket}
  end

  def user_changeset(params) do
    %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.changeset(params)
    |> Map.put(:action, :insert)
  end

  defp seo_tags(socket) do
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "ثبت نام کاربر",
      description: "ثبت نام کاربر در سایت تگرگ",
      type: "website",
      keywords: "ثبت نام کاربر",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end

  defp get_google_recaptcha_and_filtered_params(params) do
    token = params["g-recaptcha-response"]
    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })
    {token, filtered_params}
  end

  defp on_user_after_save_failure(error, user_ip, socket) do
    state = %MishkaInstaller.Reference.OnUserAfterSaveFailure{
      error: error, ip: user_ip, endpoint: :api, status: :added, conn: socket, modifier_user: :self
    }
    MishkaInstaller.Hook.call(event: "on_user_after_save_failure", state: state)
  end
end
