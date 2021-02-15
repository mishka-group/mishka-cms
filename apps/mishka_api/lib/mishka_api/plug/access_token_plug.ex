defmodule MishkaApi.Plug.AccessTokenPlug do
  # import plug module

  # use check token with type which is gotten on config file
  # return http status
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
        conn
        |> put_status(401)
        |> json(%{
          action: :change_password,
          system: :user,
          message: "شما به این صفحه دسترسی ندارید لطفا در هنگام ارسال درخواست توکن خود را ارسال فرمایید."
        })
        |> halt()


      {:error, :access, :invalid} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :change_password,
          system: :user,
          message: "توکن شما نامعتبر است"
        })
        |> halt()

      {:error, :verify_token, :access, :expired} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :change_password,
          system: :user,
          message: "توکن شما منقضی شده است"
        })
        |> halt()

      {:error, :verify_token, :access, _type} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :change_password,
          system: :user,
          message: "توکن شما نامعتبر است"
        })
        |> halt()

    end
  end

end
