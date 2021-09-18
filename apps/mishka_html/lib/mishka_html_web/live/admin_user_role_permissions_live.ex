defmodule MishkaHtmlWeb.AdminUserRolePermissionsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Permission

  # TODO: change module
  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaUser.Acl.Permission,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminUserView, "admin_user_role_permissions_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do:  Permission.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت دسترسی ها"),
        body_color: "#a29ac3cf",
        basic_menu: false,
        changeset: permission_changeset(),
        id: nil,
        user_id: Map.get(session, "user_id"),
        draft_id: nil,
        permissions: []
      )
      {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    socket =
      socket
      |> assign(id: id)
      |> assign(permissions: Permission.permissions(id))

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminUserRolesLive))}
  end

  @impl true
  def handle_event("save", %{"permission" => params}, socket) do
    user_permission = "#{params["section"]}:#{params["permission"]}"
    socket = case Permission.create(%{value: if(user_permission == "*:*", do: "*", else: user_permission), role_id: socket.assigns.id}) do
      {:error, :add, :permission, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :permission, repo_data} ->
        MishkaUser.Acl.AclTask.update_role(repo_data.role_id)
        socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    case Permission.delete(id) do
      {:ok, :delete, :permission, record} -> MishkaUser.Acl.AclTask.delete_role(record.role_id)
      _ -> nil
    end

    socket =
      socket
      |> assign(permissions: Permission.permissions(socket.assigns.id))
    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminUserRolePermissionsLive")


  @impl true
  def handle_info({:permission, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        socket
        |> assign(permissions: Permission.permissions(socket.assigns.id))
       _ ->  socket
    end
    {:noreply, socket}
  end

  defp permission_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaUser.Permission.changeset(
      %MishkaDatabase.Schema.MishkaUser.Permission{}, params
    )
  end
end
