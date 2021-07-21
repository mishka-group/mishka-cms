defmodule MishkaHtmlWeb.RegisterLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    # we need to input seo tags

    changeset = %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.changeset()

    socket =
      assign(socket,
        page_title: "ثبت نام کاربر",
        body_color: "#40485d",
        changeset: changeset,
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    case MishkaUser.User.create(params, ["full_name", "email", "password", "username", "unconfirmed_email"]) do
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
    changeset = user_changeset(params)
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

end
