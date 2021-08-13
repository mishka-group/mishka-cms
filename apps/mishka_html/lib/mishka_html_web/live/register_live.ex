defmodule MishkaHtmlWeb.RegisterLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    changeset = %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.changeset()

    socket =
      assign(socket,
        page_title: "ثبت نام کاربر",
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        changeset: changeset,
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })
    case MishkaUser.User.create(filtered_params, ["full_name", "email", "password", "username", "unconfirmed_email"]) do
      {:ok, :add, _error_tag, repo_data} ->
        MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})
        socket =
          socket
          |> put_flash(:info, "ثبت نام شما موفقیت آمیز بوده است و هم اکنون می توانید وارد سایت شوید. لطفا برای دسترسی کامل به سایت حساب کاربر خود را فعال کنید. برای فعال سازی لطفا به ایمیل خود سر زده و روی لینک یا کد فعال سازی که برای شما ارسال گردیده است کلیک کنید.")
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.LoginLive))

        {:noreply, socket}

      {:error, :add, _error_tag, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"user" => params}, socket) do

    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })

    changeset = user_changeset(filtered_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.RegisterLive"})
    {:noreply, socket}
  end

  def user_changeset(params) do
    %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.changeset(params)
    |> Map.put(:action, :insert)
  end

  defp seo_tags(socket) do
    # TODO: should change with site address
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
