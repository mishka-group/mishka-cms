defmodule MishkaHtmlWeb.AdminUserRolesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Role
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
      page_size: 10,
      filters: %{},
      page: 1,
      open_modal: false,
      component: nil,
      page_title: "نقش های کاربری",
      body_color: "#a29ac3cf",
      roles: Role.roles(conditions: {1, 20}, filters: %{})
    )
    {:ok, socket, temporary_assigns: [roles: []]}
  end

  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    {:noreply,
      role_assign(socket, params: params["params"], page_size: count, page_number: page)
    }
  end

  def handle_params(%{"page" => page}, _url, socket) do
    {:noreply,
      role_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)
    }
  end

  def handle_params(%{"count" => count} = params, _url, socket) do
    {:noreply,
      role_assign(socket, params: params["params"], page_size: count, page_number: 1)
    }
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: role_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: true])}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: false, component: nil])}
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    MishkaUser.Acl.AclTask.delete_role(id)
    case Role.delete(id) do
      {:ok, :delete, :role, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "نقش: #{MishkaHtml.full_name_sanitize(repo_data.name)} حذف شده است."})
        socket = role_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

        {:noreply, socket}

      {:error, :delete, :forced_to_delete, :role} ->

        socket =
          socket
          |> assign([
            open_modal: true,
            component: MishkaHtmlWeb.Admin.Role.DeleteErrorComponent
          ])

        {:noreply, socket}

      {:error, :delete, type, :role} when type in [:uuid, :get_record_by_id] ->

        socket =
          socket
          |> put_flash(:warning, "چنین نقشی برای دسترسی وجود ندارد یا ممکن است از قبل حذف شده باشد.")

        {:noreply, socket}

      {:error, :delete, :role, _repo_error} ->

        socket =
          socket
          |> put_flash(:error, "خطا در حذف نقش برای دسترسی اتفاق افتاده است.")

        {:noreply, socket}
    end
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminUserRolesLive"})
    {:noreply, socket}
  end

  def handle_info({:role, :ok, repo_record}, socket) do
    case repo_record.__meta__.state do
      :loaded ->

        socket = role_assign(
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

  defp role_filter(params) when is_map(params) do
    Map.take(params, Role.allowed_fields(:string))
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp role_filter(_params), do: %{}

  defp role_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          roles: Role.roles(conditions: {page, count}, filters: role_filter(params)),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end
end
