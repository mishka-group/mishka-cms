defmodule MishkaHtmlWeb.AdminUserRolePermissionsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Permission

  def mount(_params, _session, socket) do
    if connected?(socket), do:  Permission.subscribe()
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "مدیریت دسترسی ها",
        body_color: "#a29ac3cf",
        basic_menu: false,
        changeset: permission_changeset(),
        id: nil,
        permissions: []
      )
      {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    socket =
      socket
      |> assign(id: id)
      |> assign(permissions: Permission.permissions(id))

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminUserRolesLive))}
  end

  def handle_event("save", %{"permission" => params}, socket) do
    user_permission = "#{params["section"]}:#{params["permission"]}"
    case Permission.create(%{value: user_permission, role_id: socket.assigns.id}) do
      {:error, :add, :permission, repo_error} ->
        socket =
          socket
          |> assign([changeset: repo_error])
        {:noreply, socket}

      {:ok, :add, :permission, _repo_data} ->  {:noreply, socket}
    end
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    Permission.delete(id)
    socket =
      socket
      |> assign(permissions: Permission.permissions(socket.assigns.id))
    {:noreply, socket}
  end

  def handle_info({:permission, :ok, repo_record}, socket) do
    case repo_record.__meta__.state do
      :loaded ->
        socket =
          socket
          |> assign(permissions: Permission.permissions(socket.assigns.id))

        {:noreply, socket}

      :deleted -> {:noreply, socket}
       _ ->  {:noreply, socket}
    end
  end

  defp permission_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaUser.Permission.changeset(
      %MishkaDatabase.Schema.MishkaUser.Permission{}, params
    )
  end
end
