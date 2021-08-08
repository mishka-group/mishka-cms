defmodule MishkaHtmlWeb.ResetPasswordLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaDatabase.Cache.RandomCode
  # TODO: should be on config file or ram
  @hard_secret_random_link "Test refresh"

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "فراموشی پسورد",
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"email" => email}, socket) do
    # TODO: if Capcha code is true
    with {:ok, :get_record_by_field, :user, repo_data} <- MishkaUser.User.show_by_email(email),
         {:random_code, true} <- {:random_code, is_nil(MishkaDatabase.Cache.RandomCode.get_code_with_email(email))} do

          random_link = Phoenix.Token.sign(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, %{id: repo_data.id, type: "access"}, [key_digest: :sha256])
          RandomCode.save(repo_data.email, random_link)

          site_link =
            """
              <p style="color:#BDBDBD; line-height: 9px">
                <a href="#{MishkaHtmlWeb.Router.Helpers.url(socket) <> Routes.live_path(socket, __MODULE__, random_link)}" style="color: #3498DB;">
                  #{MishkaHtmlWeb.Router.Helpers.url(socket) <> Routes.live_path(socket, __MODULE__, random_link)}
                </a>
              </p>
              <hr>
              <p style="color:#BDBDBD; line-height: 9px">
                copy: #{MishkaHtmlWeb.Router.Helpers.url(socket) <> Routes.live_path(socket, __MODULE__, random_link)}
              </p>
            """


          MishkaContent.Email.EmailHelper.send(:forget_password, {repo_data.email, site_link})

    else
      # TODO: should save ip and email on state ro rate limit
      {:error, :get_record_by_field, _error_tag} -> {:error, :get_record_by_field}
      {:random_code, false} -> {:random_code, false}
    end

    socket =
      socket
      |> put_flash(:info, "در صورتی که در بانک اطلاعاتی ما حساب کاربری ای داشته باشید یا در ۵ دقیقه اخیر درخواست فراموشی پسورد ارسال نکرده باشید به زودی برای شما یک ایمیل ارسال خواهد شد. لازم به ذکر است در صورت نبودن ایمیل در اینباکس لطفا محتوای اسپم یا جانک میل را نیز چک فرمایید.")
      |> push_redirect(to: Routes.live_path(socket, __MODULE__))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.ResetPasswordLive"})
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
