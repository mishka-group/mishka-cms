defmodule MishkaApi.Plug.AccessTokenPlug do
  # use check token with type which is gotten on config file

  import Plug.Conn
  use MishkaApiWeb, :controller
  alias MishkaUser.Token.Token

  def init(default), do: default

  def call(conn, _default) do
    with {:ok, :access, :valid, access_token} <- Token.get_string_token(get_req_header(conn, "authorization"), :access),
         {:ok, :verify_token, :access, clime} <- Token.verify_access_token(access_token, :phoenix_token) do

        conn
        |> assign(:user_id, clime["id"])

    else
      {:error, :access, :no_header} ->
        error_message(conn, 401, "شما به این صفحه دسترسی ندارید لطفا در هنگام ارسال درخواست توکن خود را ارسال فرمایید.")

      {:error, :verify_token, :access, :expired} ->
        error_message(conn, 401, "توکن شما منقضی شده است")

      _error ->
        error_message(conn, 401, "توکن شما نامعتبر است")
    end
  end

  defp error_message(conn, status, msg) do
    conn
    |> put_status(status)
    |> json(%{
      action: :change_password,
      system: :user,
      message: msg
    })
    |> halt()
  end
end
