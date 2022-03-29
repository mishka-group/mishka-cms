defmodule MishkaHtmlWeb.AuthController do
  use MishkaHtmlWeb, :controller
  import Plug.Conn
  require MishkaTranslator.Gettext
  alias MishkaUser.Token.Token
  alias MishkaDatabase.Cache.RandomCode
  @hard_secret_random_link "Test refresh"

  def login(conn, %{"user" => %{"email" => email, "password" => password, "g-recaptcha-response" => token}} = _params) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    with {:ok, :verify, _token_info} <- MishkaUser.Validation.GoogleRecaptcha.verify(token),
         {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_email(MishkaHtml.email_sanitize(email)),
         {:nil_password?, false} <- {:nil_password?, is_nil(user_info.password_hash)},
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password),
         {:user_is_not_deactive, false} <- {:user_is_not_deactive, user_info.status == :inactive},
         {:ok, :save_token, token} <- Token.create_token(user_info, :current) do

        state = %MishkaInstaller.Reference.OnUserAfterLogin{conn: conn, endpoint: :html, ip: user_ip, type: :email, user_info: user_info}

        MishkaInstaller.Hook.call(event: "on_user_after_login", state: state).conn
        |> renew_session()
        |> put_session(:current_token, token)
        |> put_session(:user_id, user_info.id)
        |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(user_info.id)}")
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_auth", "با موفقیت وارد شده اید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

    else
      {:nil_password?, false} ->
        on_user_login_failure(conn, user_ip, {:nil_password?, false}).conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "ممکن است ایمیل یا پسورد شما اشتباه باشد."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")

      {:user_is_not_deactive, true} ->
        on_user_login_failure(conn, user_ip, {:user_is_not_deactive, true}).conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما از قبل غیر فعال گردیده و این به درخواست صاحب حساب می باشد. برای استفاده مجدد از حساب لطفا دوباره درخواست فعال سازی از بخش کاربری را ارسال فرمایید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")

      {:error, :more_device, error_tag} ->
        on_user_login_failure(conn, user_ip, {:error, :more_device, error_tag}).conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما بیشتر از ۵ بار در سیستم های مختلف استفاده شده است. لطفا یکی از این موارد را غیر فعال کنید و خروج را بفشارید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")

      {:error, :verify, msg} ->
        on_user_login_failure(conn, user_ip, {:error, :verify, msg}).conn
        |> put_flash(:error, msg)
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")

      error ->
        on_user_login_failure(conn, user_ip, error).conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "ممکن است ایمیل یا پسورد شما اشتباه باشد."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")
    end
  end

  def login(conn, %{"params" => entry}) do
    # developer or client should send a map as params key and this map must includ struct which is your module name
    # for example Elixir.MishkaSocial.Auth.Strategy, it should be noted, this module have to have struct under itself
    convert_controller_to_protocol(conn, entry, :login)
  end

  def register(conn, %{"params" => entry}) do
    convert_controller_to_protocol(conn, entry, :register)
  end

  def log_out(conn, _params) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    if live_socket_id = get_session(conn, :live_socket_id) do
      Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
        :timer.sleep(1000)
        MishkaUser.Token.TokenManagemnt.delete_token(get_session(conn, :user_id), get_session(conn, :current_token))
      end)
      Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
        MishkaContent.Cache.BookmarkManagement.stop(get_session(conn, :user_id))
      end)
      MishkaHtmlWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    state = %MishkaInstaller.Reference.OnUserAfterLogout{conn: conn, endpoint: :api, ip: user_ip, user_id: get_session(conn, :user_id)}
    hook = MishkaInstaller.Hook.call(event: "on_user_after_logout", state: state)

    hook.conn
    |> configure_session(drop: true)
    |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.auth_path(conn, :login)}")
  end

  def verify_email(conn, %{"code" => code}) do
    random_link = RandomCode.get_code_with_code(code)
    with {:random_link, false, random_link_user_info} <- {:random_link, is_nil(random_link), random_link},
         {:code_verify, {:ok, %{id: _id, type: "access"}}} <- {:code_verify, Phoenix.Token.verify(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, "#{random_link.code}", [max_age: MishkaHtmlWeb.ResetChangePasswordLive.random_link_expire_time().age])},
         {:ok, :get_record_by_field, :user, repo_data} <- MishkaUser.User.show_by_email(random_link_user_info.email),
         {:user_is_not_deactive, true} <- {:user_is_not_deactive, repo_data.status == :registered},
         {:ok, :edit, :user, user_info} <- MishkaUser.User.edit(%{id: repo_data.id, status: "active"}) do

        # delete all randome codes of user
        RandomCode.delete_code(code, user_info.email)

        MishkaContent.General.Activity.create_activity_by_start_child(%{
          type: "internal_api",
          section: "user",
          section_id: repo_data.id,
          action: "auth",
          priority: "high",
          status: "info"
        }, %{user_action: "verify_email", cowboy_ip: to_string(:inet_parse.ntoa(conn.remote_ip)), user_id: repo_data.id})

        conn
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_auth", "ایمیل حساب کاربری شما با موفقیت تایید گردید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")


    else
      {:user_is_not_deactive, false} ->

        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما از قبل فعال سازی شده است."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

      {:error, :get_record_by_field, _error_tag} ->

        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما بافت نشد. این اتفاق در زمانی روخ می دهد که از قبل حساب کاربری شما غیر فعال یا حذف شده باشد"))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

      _ ->

        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "کد فعال سازی حساب کاربری شما غیر معتبر است یا منقضی شده است. لطفا دوباره تلاش کنید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

    end
  end

  def deactive_account(conn, %{"code" => code}) do
    random_link = RandomCode.get_code_with_code(code)
    with {:random_link, false, random_link_user_info} <- {:random_link, is_nil(random_link), random_link},
         {:code_verify, {:ok, %{id: _id, type: "access"}}} <- {:code_verify, Phoenix.Token.verify(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, "#{random_link.code}", [max_age: MishkaHtmlWeb.ResetChangePasswordLive.random_link_expire_time().age])},
         {:ok, :get_record_by_field, :user, repo_data} <- MishkaUser.User.show_by_email(random_link_user_info.email),
         {:user_is_not_deactive, false} <- {:user_is_not_deactive, repo_data.status == :inactive},
         {:ok, :edit, :user, user_info} <- MishkaUser.User.edit(%{id: repo_data.id, status: "inactive"}) do

        MishkaContent.General.Activity.create_activity_by_start_child(%{
          type: "internal_api",
          section: "user",
          section_id: repo_data.id,
          action: "auth",
          priority: "high",
          status: "info"
        }, %{user_action: "deactive_account", cowboy_ip: to_string(:inet_parse.ntoa(conn.remote_ip)), user_id: repo_data.id})

        # clean all the token OTP
        MishkaUser.Token.TokenManagemnt.stop(user_info.id)
        # clean all the token on disc
        MishkaDatabase.Cache.MnesiaToken.delete_all_user_tokens(user_info.id)
        # delete all randome codes of user
        RandomCode.delete_code(code, user_info.email)
        # delete all user's ACL
        MishkaUser.Acl.AclManagement.stop(user_info.id)

        if live_socket_id = get_session(conn, :live_socket_id) do

          Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
            :timer.sleep(1000)
            MishkaUser.Token.TokenManagemnt.delete_token(get_session(conn, :user_id), get_session(conn, :current_token))
          end)

          Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
            MishkaContent.Cache.BookmarkManagement.stop(get_session(conn, :user_id))
          end)

          MishkaHtmlWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
        end

        conn
        |> configure_session(drop: true)
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری غیرفعال سازی گردید. اگر نیازمند به استفاده مجدد هست از بخش کاربری دوباره درخواست فعال سازی حساب را ارسال فرمایید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

    else
      {:user_is_not_deactive, true} ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما از قبل غیر فعال شده است."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

      {:error, :get_record_by_field, _error_tag} ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما بافت نشد. این اتفاق در زمانی روخ می دهد که از قبل حساب کاربری شما غیر فعال یا حذف شده باشد"))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

      _ ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "کد غیر فعال سازی حساب کاربری شما غیر معتبر است یا منقضی شده است. لطفا دوباره تلاش کنید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

    end
  end

  def delete_tokens(conn, %{"code" => code}) do
    random_link = RandomCode.get_code_with_code(code)
    with {:random_link, false, random_link_user_info} <- {:random_link, is_nil(random_link), random_link},
         {:code_verify, {:ok, %{id: _id, type: "access"}}} <- {:code_verify, Phoenix.Token.verify(MishkaHtmlWeb.Endpoint, @hard_secret_random_link, "#{random_link.code}", [max_age: MishkaHtmlWeb.ResetChangePasswordLive.random_link_expire_time().age])},
         {:ok, :get_record_by_field, :user, repo_data} <- MishkaUser.User.show_by_email(random_link_user_info.email) do

        MishkaContent.General.Activity.create_activity_by_start_child(%{
          type: "internal_api",
          section: "user",
          section_id: repo_data.id,
          action: "auth",
          priority: "high",
          status: "info"
        }, %{user_action: "delete_tokens", cowboy_ip: to_string(:inet_parse.ntoa(conn.remote_ip)), user_id: repo_data.id})

        # clean all the token OTP
        MishkaUser.Token.TokenManagemnt.stop(repo_data.id)
        # clean all the token on disc
        MishkaDatabase.Cache.MnesiaToken.delete_all_user_tokens(repo_data.id)
        # delete all randome codes of user
        RandomCode.delete_code(code, repo_data.email)
        # delete all user's ACL
        MishkaUser.Acl.AclManagement.stop(repo_data.id)

        if live_socket_id = get_session(conn, :live_socket_id) do

          Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
            :timer.sleep(1000)
            MishkaUser.Token.TokenManagemnt.delete_token(get_session(conn, :user_id), get_session(conn, :current_token))
          end)

          Task.Supervisor.async_nolink(MishkaHtmlWeb.AuthController.DeleteCurrentTokenTaskSupervisor, fn ->
            MishkaContent.Cache.BookmarkManagement.stop(get_session(conn, :user_id))
          end)

          MishkaHtmlWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
        end

        conn
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_auth", "تمامی توکن های شما و همینطور دستگاه های آنلاین به حساب کاربری شما با موفقیت پاکسازی و خارج شدند"))
        |> configure_session(drop: true)
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

    else
      {:error, :get_record_by_field, _error_tag} ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "حساب کاربری شما بافت نشد. این اتفاق در زمانی روخ می دهد که از قبل حساب کاربری شما غیر فعال یا حذف شده باشد"))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")

      _ ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "کد پاکسازی توکن حساب کاربری شما غیر معتبر است یا منقضی شده است. لطفا دوباره تلاش کنید."))
        |> redirect(to: "#{MishkaHtmlWeb.Router.Helpers.live_path(conn, MishkaHtmlWeb.HomeLive)}")
    end
  end

  def renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  def get_config(item) do
    :mishka_api
    |> Application.fetch_env!(:auth)
    |> Keyword.fetch!(item)
  end

  defp on_user_login_failure(conn, user_ip, error) do
    state = %MishkaInstaller.Reference.OnUserLoginFailure{conn: conn, ip: user_ip, endpoint: :html, error: error}
    MishkaInstaller.Hook.call(event: "on_user_login_failure", state: state)
  end

  def convert_controller_to_protocol(conn, entry, action) do
    case behaviour_module(entry["struct"]) do
      {:ok, module} ->
        apply(MishkaSocial.AuthProtocol, action, [Map.merge(struct(module), convert_string_map_to_atom(entry, conn))])
      {:error, :module_not_found} -> {:error, :convert_controller_to_protocol}
    end
  end

  defp convert_string_map_to_atom(string_map, conn) do
    string_map
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.merge(%{conn: conn})
  end

  defp behaviour_module(module_name) do
    {:ok, String.to_existing_atom(module_name)}
  rescue
    _ ->{:error, :module_not_found}
  end
end
