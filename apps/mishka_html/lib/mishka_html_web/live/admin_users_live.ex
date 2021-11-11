defmodule MishkaHtmlWeb.AdminUsersLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.User
  alias MishkaHtmlWeb.Admin.User.DeleteErrorComponent
  alias MishkaContent.General.Activity

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
  def mount(_params, session, socket) do
    if connected?(socket), do: User.subscribe(); Activity.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        user_id: Map.get(session, "user_id"),
        page_title:  MishkaTranslator.Gettext.dgettext("html_live", "مدیریت کاربران"),
        body_color: "#a29ac3cf",
        users: User.users(conditions: {1, 10}, filters: %{}),
        roles: MishkaUser.Acl.Role.roles(conditions: {1, 10}, filters: %{}),
        activities: Activity.activities(conditions: {1, 5}, filters: %{section: "user"})
      )
    {:ok, socket, temporary_assigns: [users: []]}
  end

  # Live CRUD
  paginate(:users, user_id: false)

  @impl true
  def handle_event("search_role", params, socket) do
    socket =
      assign(socket,
        roles: MishkaUser.Acl.Role.roles(conditions: {1, 10}, filters: %{name: params["name"]}),
        users: User.users(conditions: {socket.assigns.page, socket.assigns.page_size}, filters: user_filter(socket.assigns.filters))
      )
    {:noreply, socket}
  end

  list_search_and_action()

  delete_list_item(:users, DeleteErrorComponent, true)

  @impl true
  def handle_event("user_role", %{"role" => role_id, "user_id" => user_id, "full_name" => full_name}, socket) do
    case role_id do
      "delete_user_role" ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "user",
          section_id: user_id,
          action: "auth",
          priority: "medium",
          status: "info",
          user_id: Map.get(socket.assigns, :user_id)
        }, %{user_action: "live_delete_user_role", type: "admin", full_name: full_name})

        title = MishkaTranslator.Gettext.dgettext("html_live", "نقش کاربری شما حذف شد")
        description = MishkaTranslator.Gettext.dgettext("html_live", "دسترسی حساب کاربری شما تغییر کرده است. این به منظور مسدود شدن شما نمی باشد. بلکه نقش کاربری از قبل داده شده پاک گردیده است. لازم به ذکر است این تغییرات به وسیله مدیریت وب سایت انجام شده است.")
        MishkaContent.General.Notif.send_notification(%{section: :user_only, type: :client, target: :all, title: title, description: description}, user_id, :repo_task)

        MishkaUser.Acl.UserRole.delete_user_role(user_id)
        MishkaUser.Acl.AclManagement.stop(user_id)
      _record ->
        create_or_edit_user_role(user_id, role_id, full_name, socket)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:activity, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        socket
        |> assign(activities: Activity.activities(conditions: {1, 5}, filters: %{section: "user"}))
       _ ->  socket
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


  defp create_or_edit_user_role(user_id, role_id, full_name, socket) do
    case MishkaUser.Acl.UserRole.show_by_user_id(user_id) do
      {:error, _, _repo_error} ->

        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "user",
          section_id: user_id,
          action: "auth",
          priority: "medium",
          status: "info",
          user_id: Map.get(socket.assigns, :user_id)
        }, %{user_action: "live_create_or_edit_user_role", type: "admin", full_name: full_name})

        MishkaUser.Acl.UserRole.create(%{user_id: user_id, role_id: role_id})

      {:ok, _error_atom, _, repo_data} ->
        MishkaUser.Acl.AclManagement.stop(user_id)
        MishkaUser.Acl.UserRole.edit(%{id: repo_data.id, user_id: user_id, role_id: role_id})
    end

    title = MishkaTranslator.Gettext.dgettext("html_live", "نقش کاربری شما تغییر داده شد")
    description = MishkaTranslator.Gettext.dgettext("html_live", "دسترسی کاربری شما به وسیله مدیریت وب سایت تغییر پیدا کرد. در صورت مشکل لطفا با پشتیبان ما در ارتباط باشید")
    MishkaContent.General.Notif.send_notification(%{section: :user_only, type: :client, target: :all, title: title, description: description}, user_id, :repo_task)

    MishkaUser.Acl.AclManagement.save(%{
      id: user_id,
      user_permission: MishkaUser.User.permissions(user_id),
      created: System.system_time(:second)},
      user_id
    )
  end
end
