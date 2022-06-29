defmodule MishkaHtmlWeb.ResetChangePasswordLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Validation.RandomCode
  # TODO: change this with config
  @hard_secret_random_link "Test refresh"

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientAuthView, "reset_change_password_live.html", assigns)
  end

  @impl true
  def mount(%{"random_link" => random_link}, session, socket) do
    state_random_link = RandomCode.get_code_with_code(random_link)

    socket =
      with {:code_verify, {:ok, %{id: _id, type: "access"}}} <-
             {:code_verify,
              Phoenix.Token.verify(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, random_link,
                max_age: random_link_expire_time().age
              )},
           {:random_link, false, record} <-
             {:random_link, is_nil(state_random_link), state_random_link} do
        Process.send_after(self(), :menu, 100)

        assign(socket,
          page_title: MishkaTranslator.Gettext.dgettext("html_live", "تغییر پسورد کاربر"),
          seo_tags: seo_tags(socket, random_link),
          body_color: "#40485d",
          user_id: Map.get(session, "user_id"),
          random_link: record.code,
          user_email: record.email,
          errors: %{},
          self_pid: self()
        )
      else
        _ ->
          socket
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "کد ارسالی شما اشتباه می باشد یا ممکن است منقضی شده باشد. لطفا دوباره تلاش کنید"
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetPasswordLive))
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"password" => new_password}, socket) do
    socket =
      with {:ok, :get_record_by_field, :user, repo_data} <-
             MishkaUser.User.show_by_email(socket.assigns.user_email),
           {:random_link, false} <-
             {:random_link, is_nil(RandomCode.get_code_with_code(socket.assigns.random_link))},
           {:code_verify, {:ok, %{id: _id, type: "access"}}} <-
             {:code_verify,
              Phoenix.Token.verify(
                MishkaHtmlWeb.Endpoint,
                @hard_secret_random_link,
                socket.assigns.random_link,
                max_age: random_link_expire_time().age
              )},
           {:ok, :edit, :user, user_info} <-
             MishkaUser.User.edit(%{id: repo_data.id, password: new_password}) do
        MishkaContent.General.Activity.create_activity_by_start_child(
          %{
            type: "section",
            section: "user",
            section_id: repo_data.id,
            action: "edit",
            priority: "high",
            status: "info"
          },
          %{user_action: "change_password", type: "client", user_id: repo_data.id}
        )

        # Send password changed notification to a user
        title = MishkaTranslator.Gettext.dgettext("html_live", "پسورد حساب کاربری شما تغییر کرد.")

        description =
          MishkaTranslator.Gettext.dgettext(
            "html_live",
            "در صورتی که شما پسورد حساب کاربری خود را تغییر ندادید یا از این موضوع بی اطلاع هستید سریعا پسورد را تغییر داده و همینطور پسورد ایمیل خود برای جلوگیری از اتفاق مجدد. در صورت راهنمایی بیشتر لطفا با پشتیبانی ما در ارتباط باشید"
          )

        MishkaContent.General.Notif.send_notification(
          %{
            section: :user_only,
            type: :client,
            target: :all,
            title: title,
            description: description
          },
          user_info.id,
          :repo_task
        )

        # clean all the token OTP
        MishkaUser.Token.TokenManagemnt.delete(user_info.id)
        # clean all the token on disc
        MishkaUser.Token.UserToken.delete_by_user_id(user_info.id)
        # delete all randome codes of user
        RandomCode.delete_code(repo_data.email)
        # delete all user's ACL
        MishkaUser.Acl.AclManagement.delete(user_info.id)

        socket
        |> put_flash(
          :success,
          MishkaTranslator.Gettext.dgettext("html_live", "پسورد شما با موفقیت به روز رسانی شد.")
        )
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.LoginLive))
      else
        {:error, :get_record_by_field, _error_tag} ->
          socket
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "کاربر مورد نظر پیدا نشد یا از قبل حذف شده است"
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetPasswordLive))

        {:random_link, true} ->
          socket
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "کد ارسالی شما اشتباه می باشد یا ممکن است منقضی شده باشد. لطفا دوباره تلاش کنید"
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetPasswordLive))

        {:error, :edit, :uuid, _error_tag} ->
          socket
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "کاربر مورد نظر پیدا نشد یا از قبل حذف شده است"
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetPasswordLive))

        {:error, :edit, :get_record_by_id, _error_tag} ->
          socket
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "کاربر مورد نظر پیدا نشد یا از قبل حذف شده است"
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetPasswordLive))

        {:error, :edit, :user, repo_error} ->
          socket
          |> assign(errors: MishkaDatabase.translate_errors(repo_error))
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "خطایی در به روز رسانی حساب پیش آمده است."
            )
          )

        _ ->
          socket
          |> put_flash(
            :error,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "کد ارسالی شما اشتباه می باشد یا ممکن است منقضی شده باشد. لطفا دوباره تلاش کنید"
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetPasswordLive))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers(
      {:menu, "Elixir.MishkaHtmlWeb.LoginLive", socket.assigns.self_pid}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info(_params, socket) do
    {:noreply, socket}
  end

  defp seo_tags(socket, random_link) do
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)

    %{
      image: "#{site_link}/images/mylogo.png",
      title: "تغییر پسورد کاربر",
      description: "تغییر پسورد کاربر",
      type: "website",
      keywords: "فراموشی پسورد, تغییر پسورد",
      link: site_link <> Routes.live_path(socket, __MODULE__, random_link)
    }
  end

  def random_link_expire_time() do
    %{
      unix_time: DateTime.utc_now() |> DateTime.add(600, :second) |> DateTime.to_unix(),
      age: 600
    }
  end
end
