defmodule MishkaHtmlWeb.RegisterLive do
  use MishkaHtmlWeb, :live_view

  # TODO: should be on config file or ram
  @hard_secret_random_link "Test refresh"
  alias MishkaDatabase.Cache.RandomCode

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
        self_pid: self()
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    token = params["g-recaptcha-response"]
    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })


    socket = with {:ok, :verify, _token_info} <- MishkaUser.Validation.GoogleRecaptcha.verify(token),
                  {:ok, :add, _error_tag, repo_data} <- MishkaUser.User.create(filtered_params, ["full_name", "email", "password", "username", "unconfirmed_email"]) do
      MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})

        random_link = Phoenix.Token.sign(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, %{id: repo_data.id, type: "access"}, [key_digest: :sha256])
        RandomCode.save(repo_data.email, random_link)

        site_link = MishkaContent.Email.EmailHelper.email_site_link_creator(
          MishkaHtmlWeb.Router.Helpers.url(socket),
          MishkaHtmlWeb.Router.Helpers.auth_path(socket, :verify_email, random_link)
        )

          MishkaContent.Email.EmailHelper.send(:verify_email, {repo_data.email, site_link})

          MishkaContent.General.Activity.create_activity_by_task(%{
            type: "section",
            section: "user",
            section_id: repo_data.id,
            action: "add",
            priority: "low",
            status: "info",
            user_id: repo_data.id
          }, %{user_action: "register", identity_provider: "self", type: "client"})

          socket
          |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "ثبت نام شما موفقیت آمیز بوده است و هم اکنون می توانید وارد سایت شوید. لطفا برای دسترسی کامل به سایت حساب کاربر خود را فعال کنید. برای فعال سازی لطفا به ایمیل خود سر زده و روی لینک یا کد فعال سازی که برای شما ارسال گردیده است کلیک کنید."))
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.LoginLive))

    else
      {:error, :add, _error_tag, changeset} -> assign(socket, changeset: changeset)

      {:error, :verify, msg} ->

        socket
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
end
