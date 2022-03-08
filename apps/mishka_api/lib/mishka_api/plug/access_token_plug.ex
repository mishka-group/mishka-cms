defmodule MishkaApi.Plug.AccessTokenPlug do
  # use check token with type which is gotten on config file
  require MishkaTranslator.Gettext

  import Plug.Conn
  use MishkaApiWeb, :controller
  alias MishkaUser.Token.Token

  def init(default), do: default

  def call(conn, _default) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    with {:ok, :access, :valid, access_token} <- Token.get_string_token(get_req_header(conn, "authorization"), :access),
         {:ok, :verify_token, :access, clime} <- Token.verify_access_token(access_token, MishkaApi.get_config(:token_type)) do

        on_user_authorisation(conn, clime["id"], user_ip).conn
        |> assign(:user_id, clime["id"])

    else
      {:error, :access, :no_header} ->
        on_user_authorisation_failure(conn, user_ip, {:error, :access, :no_header}).conn
        |> error_message(401, MishkaTranslator.Gettext.dgettext("api_auth", "شما به این صفحه دسترسی ندارید لطفا در هنگام ارسال درخواست توکن خود را ارسال فرمایید."))

      {:error, :verify_token, :access, :expired} ->
        on_user_authorisation_failure(conn, user_ip, {:error, :verify_token, :access, :expired}).conn
        |> error_message(401, MishkaTranslator.Gettext.dgettext("api_auth", "توکن شما منقضی شده است"))

      error ->
        on_user_authorisation_failure(conn, user_ip, error).conn
        |> error_message(401, MishkaTranslator.Gettext.dgettext("api_auth", "توکن شما منقضی شده است"))
    end
  end

  defp error_message(conn, status, msg) do
    conn
    |> put_status(status)
    |> json(%{action: :access_token, system: :user, message: msg})
    |> halt()
  end

  defp on_user_authorisation_failure(conn, user_ip, error, extra \\ []) do
    state = %MishkaInstaller.Reference.OnUserAuthorisationFailure{
      conn: conn, ip: user_ip, endpoint: :api, error: error, module: __MODULE__, operation: :call, extra: extra
    }
    MishkaInstaller.Hook.call(event: "on_user_authorisation_failure", state: state)
  end

  defp on_user_authorisation(conn, user_id, user_ip, extra \\ []) do
    state = %MishkaInstaller.Reference.OnUserAuthorisation{
      conn: conn, user_id: user_id, ip: user_ip, endpoint: :api, module: __MODULE__, operation: :call, extra: extra
    }
    MishkaInstaller.Hook.call(event: "on_user_authorisation", state: state)
  end
end
