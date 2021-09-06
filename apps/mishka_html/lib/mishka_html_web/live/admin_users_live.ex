defmodule MishkaHtmlWeb.AdminUsersLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.User
  alias MishkaHtmlWeb.Admin.User.DeleteErrorComponent

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaUser.User,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["role"]

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminUserView, "admin_users_live.html", assigns)
  end

  @impl true
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
        page_title:  MishkaTranslator.Gettext.dgettext("html_live", "مدیریت کاربران"),
        body_color: "#a29ac3cf",
        users: User.users(conditions: {1, 10}, filters: %{}),
        roles: MishkaUser.Acl.Role.roles(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [users: []]}
  end

  # Live CRUD
  paginate(:users, user_id: false)

  list_search_and_action()

  delete_list_item(:users, DeleteErrorComponent, false)

  @impl true
  def handle_event("search_role", params, socket) do
    socket =
      assign(socket,
        roles: MishkaUser.Acl.Role.roles(conditions: {1, 10}, filters: %{name: params["name"]}),
        users: User.users(conditions: {socket.assigns.page, socket.assigns.page_size}, filters: user_filter(socket.assigns.filters))
      )
    {:noreply, socket}
  end

  @impl true
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

  selected_menue("MishkaHtmlWeb.AdminUsersLive")

  update_list(:users, false)

  defp user_filter(params) when is_map(params) do
    Map.take(params, User.allowed_fields(:string) ++ ["role"])
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp user_filter(_params), do: %{}


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
