defmodule MishkaApi.Plug.AclCheckPlug do
  import Plug.Conn
  use MishkaApiWeb, :controller


  def init(default), do: default

  def call(conn, _default) do
    module = case Enum.join(conn.path_info, "/") do
      "" -> "NotFound"
      module -> module
    end

    acl_got = Map.get(MishkaUser.Acl.Action.actions(:api), module |> to_string())

    get_user_id = Map.get(conn.assigns, :user_id)

    with {:acl_check, false, action} <- {:acl_check, is_nil(acl_got), acl_got},
         {:user_id_check, false, user_id} <- {:user_id_check, is_nil(get_user_id), get_user_id},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          conn
    else
      {:acl_check, true, nil} -> conn

      {:user_id_check, true, nil} ->
        error_message(conn, 401, "شما به این صفحه دسترسی ندارید.")

      {:permittes?, false} ->
        error_message(conn, 401, "شما به این صفحه دسترسی ندارید.")
    end
  end

  defp error_message(conn, status, msg) do
    conn
    |> put_status(status)
    |> json(%{
      action: :permission,
      system: :user,
      message: msg
    })
    |> halt()
  end
end
