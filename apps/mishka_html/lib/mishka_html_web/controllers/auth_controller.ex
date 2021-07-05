defmodule MishkaHtmlWeb.AuthController do
  use MishkaHtmlWeb, :controller
  import Plug.Conn
  alias MishkaUser.Token.Token

  def login(conn, %{"user" => %{"email" => email, "password" => password}} = _params) do
    # to_string(:inet_parse.ntoa(conn.remote_ip))
    with {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_email(email),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password),
         {:ok, :save_token, token} <- Token.create_token(user_info, :current) do


        conn
        |> renew_session()
        |> put_session(:current_token, token)
        |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(user_info.id)}")
        |> put_flash(:info, "با موفقیت وارد شده اید.")
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

    else
      {:error, :more_device, _error_tag} ->
        conn
        |> put_flash(:error, "حساب کاربری شما بیشتر از ۵ بار در سیستم های مختلف استفاده شده است. لطفا یکی از این موارد را غیر فعال کنید و خروج را بفشارید.")
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")

      _error ->
        conn
        |> put_flash(:error, "ممکن است ایمیل یا پسورد شما اشتباه باشد.")
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")
    end
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  def get_config(item) do
    :mishka_api
    |> Application.fetch_env!(:auth)
    |> Keyword.fetch!(item)
  end
end
