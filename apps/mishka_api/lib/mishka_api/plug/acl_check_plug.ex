defmodule MishkaApi.Plug.AclCheckPlug do
  import Plug.Conn
  use MishkaApiWeb, :controller
  require MishkaTranslator.Gettext

  def init(default), do: default

  def call(conn, _default) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    module = case Enum.join(conn.path_info, "/") do
      "" -> "NotFound"
      module -> module
    end

    acl_got = Map.get(MishkaUser.Acl.Action.actions(:api), module |> to_string())

    get_user_id = Map.get(conn.assigns, :user_id)

    with {:acl_check, false, action} <- {:acl_check, is_nil(acl_got), acl_got},
         {:user_id_check, false, user_id} <- {:user_id_check, is_nil(get_user_id), get_user_id},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          on_user_authorisation(conn, user_id, user_ip).conn
    else
      {:acl_check, true, nil} -> on_user_authorisation(conn, get_user_id, user_ip).conn

      {:user_id_check, true, nil} ->
        on_user_authorisation_failure(conn, user_ip, {:user_id_check, true, nil}).conn
        |> error_message(401, MishkaTranslator.Gettext.dgettext("api_auth", "شما به این صفحه دسترسی ندارید."))

      {:permittes?, false} ->
        on_user_authorisation_failure(conn, user_ip, {:permittes?, false}).conn
        |> error_message(401, MishkaTranslator.Gettext.dgettext("api_auth", "شما به این صفحه دسترسی ندارید."))
    end
  end

  defp error_message(conn, status, msg) do
    conn
    |> put_status(status)
    |> json(%{action: :permission, system: :user, message: msg})
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
