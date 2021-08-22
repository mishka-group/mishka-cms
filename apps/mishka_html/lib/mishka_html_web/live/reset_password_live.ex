defmodule MishkaHtmlWeb.ResetPasswordLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaDatabase.Cache.RandomCode
  # TODO: should be on config file or ram
  @hard_secret_random_link "Test refresh"

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientAuthView, "reset_password_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "فراموشی پسورد"),
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"random_link" => random_link}, _url, socket) do
    random_code = RandomCode.get_code_with_code(random_link)
    socket = with {:random_code, false, random_code_info} <- {:random_code, is_nil(random_code), random_code},
         {:ok, :get_record_by_field, :user, _repo_data} <- MishkaUser.User.show_by_email(random_code_info.email) do

          socket
          |> put_flash(:success, MishkaTranslator.Gettext.dgettext("html_live", "کد ارسالی از طرف شما صحیح می باشد. لطفا پسورد جدید خود را وارد کنید."))
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.ResetChangePasswordLive, random_link))
    else
      {:random_code, true, _random_code_info} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "کد ارسالی شما اشتباه می باشد. لطفا دوباره تلاش کنید"))
        |> push_redirect(to: Routes.live_path(socket, __MODULE__))

      {:error, :get_record_by_field, _error_tag} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین کاربری وجود ندارد یا حذف شده است."))
        |> push_redirect(to: Routes.live_path(socket, __MODULE__))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"email" => email}, socket) do
    # TODO: if Capcha code is true
    with {:ok, :get_record_by_field, :user, repo_data} <- MishkaUser.User.show_by_email(MishkaHtml.email_sanitize(email)),
         {:random_code, true} <- {:random_code, is_nil(MishkaDatabase.Cache.RandomCode.get_code_with_email(MishkaHtml.email_sanitize(email)))} do

          random_link = Phoenix.Token.sign(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, %{id: repo_data.id, type: "access"}, [key_digest: :sha256])
          RandomCode.save(repo_data.email, random_link)

          site_link = MishkaContent.Email.EmailHelper.email_site_link_creator(
              MishkaHtmlWeb.Router.Helpers.url(socket),
              Routes.live_path(socket, __MODULE__, random_link)
            )

          MishkaContent.Email.EmailHelper.send(:forget_password, {repo_data.email, site_link})

    else
      # TODO: should save ip and email on state ro rate limit
      {:error, :get_record_by_field, _error_tag} -> {:error, :get_record_by_field}
      {:random_code, false} -> {:random_code, false}
    end

    socket =
      socket
      |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "در صورتی که در بانک اطلاعاتی ما حساب کاربری ای داشته باشید یا در ۵ دقیقه اخیر درخواست فراموشی پسورد ارسال نکرده باشید به زودی برای شما یک ایمیل ارسال خواهد شد. لازم به ذکر است در صورت نبودن ایمیل در اینباکس لطفا محتوای اسپم یا جانک میل را نیز چک فرمایید."))
      |> push_redirect(to: Routes.live_path(socket, __MODULE__))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.LoginLive"})
    {:noreply, socket}
  end

  defp seo_tags(socket) do
    # TODO: should change with site address
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "فراموشی پسورد",
      description: "فراموشی پسورد در سایت تگرگ",
      type: "website",
      keywords: "فراموشی پسورد",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end
end
