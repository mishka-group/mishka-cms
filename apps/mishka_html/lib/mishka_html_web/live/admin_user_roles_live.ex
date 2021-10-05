defmodule MishkaHtmlWeb.AdminUserRolesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Role
  alias MishkaHtmlWeb.Admin.Role.DeleteErrorComponent
  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaUser.Acl.Role,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminUserView, "admin_user_roles_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
      page_size: 10,
      filters: %{},
      page: 1,
      open_modal: false,
      component: nil,
      user_id: Map.get(session, "user_id"),
      page_title: MishkaTranslator.Gettext.dgettext("html_live", "نقش های کاربری"),
      body_color: "#a29ac3cf",
      roles: Role.roles(conditions: {1, 10}, filters: %{})
    )
    {:ok, socket, temporary_assigns: [roles: []]}
  end

  # Live CRUD
  paginate(:roles, user_id: false)

  list_search_and_action()

  delete_list_item(:roles, DeleteErrorComponent, false, do: fn data ->
    data
  end, before: fn x -> MishkaUser.Acl.AclTask.delete_role(x) end)

  selected_menue("MishkaHtmlWeb.AdminUserRolesLive")

  update_list(:roles, false)

end
