defmodule MishkaHtmlWeb.AdminUsersLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.User

  def mount(_params, _session, socket) do
    if connected?(socket), do: User.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: "مدیریت کاربران",
        body_color: "#a29ac3cf",
        users: User.users(conditions: {1, 10}, filters: %{}),
        roles: MishkaUser.Acl.Role.roles(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [users: []]}
  end

  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    {:noreply,
      user_assign(socket, params: params["params"], page_size: count, page_number: page)
    }
  end

  def handle_params(%{"page" => page}, _url, socket) do
    {:noreply,
      user_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)
    }
  end

  def handle_params(%{"count" => count} = params, _url, socket) do
    {:noreply,
      user_assign(socket, params: params["params"], page_size: count, page_number: 1)
    }
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search_role", params, socket) do
    socket =
      assign(socket,
        roles: MishkaUser.Acl.Role.roles(conditions: {1, 10}, filters: %{name: params["name"]}),
        users: User.users(conditions: {socket.assigns.page, socket.assigns.page_size}, filters: user_filter(socket.assigns.filters))
      )
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: user_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    case User.delete(id) do
      {:ok, :delete, :user, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "کاربر: #{MishkaHtml.full_name_sanitize(repo_data.full_name)} حذف شده است."})

        socket = user_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

        {:noreply, socket}

      {:error, :delete, :forced_to_delete, :user} ->

        socket =
          socket
          |> assign([
            open_modal: true,
            component: MishkaHtmlWeb.Admin.User.DeleteErrorComponent
          ])

        {:noreply, socket}

      {:error, :delete, type, :user} when type in [:uuid, :get_record_by_id] ->

        socket =
          socket
          |> put_flash(:warning, "چنین کاربری وجود ندارد یا ممکن است از قبل حذف شده باشد.")

        {:noreply, socket}

      {:error, :delete, :user, _repo_error} ->

        socket =
          socket
          |> put_flash(:error, "خطایی در حذف کاربر اتفاق افتاده است.")

        {:noreply, socket}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: false, component: nil])}
  end

  def handle_event("user_role", %{"role" => role_id, "user_id" => user_id}, socket) do
    case role_id do
      "delete_user_role" ->
        MishkaUser.Acl.UserRole.delete_user_role(user_id)
        MishkaUser.Acl.AclManagement.stop(user_id)
      _record ->
        create_or_edit_user_role(user_id, role_id)
    end

    {:noreply, socket}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminUsersLive"})
    {:noreply, socket}
  end

  def handle_info({:user, :ok, repo_record}, socket) do
    case repo_record.__meta__.state do
      :loaded ->

        socket = user_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

        {:noreply, socket}

      :deleted -> {:noreply, socket}
       _ ->  {:noreply, socket}
    end
  end

  defp user_filter(params) when is_map(params) do
    Map.take(params, User.allowed_fields(:string) ++ ["role"])
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp user_filter(_params), do: %{}


  defp user_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          users: User.users(conditions: {page, count}, filters: user_filter(params)),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end

  defp create_or_edit_user_role(user_id, role_id) do
    case MishkaUser.Acl.UserRole.show_by_user_id(user_id) do
      {:error, _, _} ->
        MishkaUser.Acl.UserRole.create(%{user_id: user_id, role_id: role_id})

      {:ok, _, _, repo_data} ->
        MishkaUser.Acl.AclManagement.stop(user_id)
        MishkaUser.Acl.UserRole.edit(%{id: repo_data.id, user_id: user_id, role_id: role_id})
    end

    MishkaUser.Acl.AclManagement.save(%{
      id: user_id,
      user_permission: MishkaUser.User.permissions(user_id),
      created: System.system_time(:second)},
      user_id
    )
  end
end
