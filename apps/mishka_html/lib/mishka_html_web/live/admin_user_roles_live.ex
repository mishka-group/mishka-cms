defmodule MishkaHtmlWeb.AdminUserRolesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Role

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaUser.Acl.Role,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminUserView, "admin_user_roles_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
      page_size: 10,
      filters: %{},
      page: 1,
      open_modal: false,
      component: nil,
      page_title: MishkaTranslator.Gettext.dgettext("html_live", "نقش های کاربری"),
      body_color: "#a29ac3cf",
      roles: Role.roles(conditions: {1, 20}, filters: %{})
    )
    {:ok, socket, temporary_assigns: [roles: []]}
  end

  # Live CRUD
  paginate(:roles, user_id: false)

  list_search_and_action()

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    MishkaUser.Acl.AclTask.delete_role(id)
    socket = case Role.delete(id) do
      {:ok, :delete, :role, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "نقش: %{title} حذف شده است.", title: MishkaHtml.full_name_sanitize(repo_data.name))})
        role_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

      {:error, :delete, :forced_to_delete, :role} ->
        socket
        |> assign([
          open_modal: true,
          component: MishkaHtmlWeb.Admin.Role.DeleteErrorComponent
        ])

      {:error, :delete, type, :role} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning,  MishkaTranslator.Gettext.dgettext("html_live", "چنین نقشی برای دسترسی وجود ندارد یا ممکن است از قبل حذف شده باشد."))

      {:error, :delete, :role, _repo_error} ->
        socket
        |> put_flash(:error,  MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف نقش برای دسترسی اتفاق افتاده است."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminUserRolesLive"})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:role, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        role_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

       _ ->  socket
    end

    {:noreply, socket}
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
