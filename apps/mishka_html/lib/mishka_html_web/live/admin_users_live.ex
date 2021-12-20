defmodule MishkaHtmlWeb.AdminUsersLive do
  use MishkaHtmlWeb, :live_view

  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت کاربران")
  alias MishkaUser.User
  alias MishkaContent.General.Activity

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaUser.User,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["role"]

  @impl true
  def render(assigns) do
    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@users}
        url={MishkaHtmlWeb.AdminUsersLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, MishkaHtmlWeb.Admin.Public.AdminMenu, id: :admin_menu)}
        left_header_side={MishkaHtmlWeb.Helpers.ActivitiesComponent.activities(assigns, section_info(assigns, @socket).activities_info)}
      />
    """
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
        page_title:  @section_title,
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
        |> assign(
          activities: Activity.activities(conditions: {1, 5}, filters: %{section: "user"}),
          users: User.users(conditions: {socket.assigns.page, socket.assigns.page_size}, filters: socket.assigns.filters)
        )
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

  defp user_temporary_image() do
    """
    <div class="align-middle admin-list-img">
      <img src="/images/no-user-image.jpg">
    </div>
    """
  end
  def section_fields() do
    [
      ListItemComponent.custom_field("user_image", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "تصویر"), user_temporary_image(),
      {true, false, false}),
      ListItemComponent.text_field("full_name", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "نام کامل"),
      {true, true, true}),
      ListItemComponent.text_field("username", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "نام کاربری"),
      {true, true, true}),
      ListItemComponent.text_field("email", [1], "col-sm header4", MishkaTranslator.Gettext.dgettext("html_live",  "ایمیل"),
      {true, true, true}),
      ListItemComponent.select_field("status", [1, 4], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "وضعیت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "ثبت نام شده"), "registered"},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال شده"), "active"},
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
      ],
      {true, true, true}),
      ListItemComponent.select_field("role", [1, 4], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "نقش"),
      Enum.map(MishkaUser.Acl.Role.roles(), fn role -> {role.display_name, role.id} end),
      {false, false, true})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "ساخت کاربر"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminUserLive),
            class: "btn btn-outline-primary"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "دسترسی ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminUserRolesLive),
            class: "btn btn-outline-info"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "نظرات"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive),
            class: "btn btn-outline-danger"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف"),
            class: "btn btn-outline-primary vazir"
          },
          %{
            method: :redirect_key,
            router: MishkaHtmlWeb.AdminUserLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "ویرایش"),
            class: "btn btn-outline-danger vazir",
            action: :id,
            key: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "کاربران"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "کاربر"),
        action: :full_name,
        action_by: :full_name,
      },
      custom_operations: [:roles, :id, :full_name],
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید کاربران سایت را مدیریت نمایید.") %>
        <div class="space30"></div>
      """
    }
  end

  def custom_operations(assigns, operations_info, parent_assigns) do
    ~H"""
      <% user_role = operations_info.roles %>
      <div class="clearfix"></div>
      <div class="space20"></div>
      <div class="col">
          <label for="country" class="form-label">
          <%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب دسترسی") %>
          </label>
          <form phx-change="search_role">
              <input class="form-control" type="text" placeholder={MishkaTranslator.Gettext.dgettext("html_live_component", "جستجوی پیشرفته")} name="name">
          </form>
          <form phx-change="user_role">
              <input type="hidden" value={operations_info.id} name="user_id">
              <input type="hidden" value={operations_info.full_name} name="full_name">
              <select class="form-select" id="role" name="role" size="2" style="min-height: 150px;">
              <option value="delete_user_role"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بدون دسترسی") %></option>
              <%= for role_item <- parent_assigns.roles.entries do %>
                  <%= if !is_nil(user_role) and role_item.id == user_role.id do %>
                      <option value={role_item.id} selected><%= role_item.name %></option>
                  <% else %>
                      <option value={role_item.id}><%= role_item.name %></option>
                  <% end %>
              <% end %>
              </select>
          </form>
      </div>
    """
  end
end
