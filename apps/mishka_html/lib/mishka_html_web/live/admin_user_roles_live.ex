defmodule MishkaHtmlWeb.AdminUserRolesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Role
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "نقش های کاربری")

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaUser.Acl.Role,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@roles}
        url={MishkaHtmlWeb.AdminUserRolesLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
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
      page_title: @section_title,
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

  def section_fields() do
    [
      ListItemComponent.text_field("name", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "نام"),
      {true, false, true}),
      ListItemComponent.text_field("display_name", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "نام نمایش"),
      {true, false, true}),
      ListItemComponent.time_field("inserted_at", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "ثبت"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "ساخت نفش"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminUserRoleLive),
            class: "btn btn-outline-danger"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برگشت به کاربران"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive),
            class: "btn btn-outline-info"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف"),
            class: "btn btn-outline-danger vazir"
          },
          %{
            method: :redirect_key,
            router: MishkaHtmlWeb.AdminUserRolePermissionsLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "مدیریت دسترسی ها"),
            class: "btn btn-outline-info vazir",
            action: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "نقش ها"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "نقش"),
        action: :section,
        action_by: :section,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "در این بخش شما می توانید نقش های کاربری را بسازید و به هر نقش یک سری سطوح دسترسی مخصوص به سایت را تخصیص بدهید. لازم به ذکر است بعد از ساخت نقش و تخصیص یک یا چند دسترسی به آن حال می توانید وارد مدیریت کاربران شده و یک کاربر را به یک نقش خاص تخصیص بدهید. در زمانی شما از نقش ها استفاده می کنید که می خواهید برخی از بخش های سایت خود را به گروه کاربری خاصی اجازه دسترسی بدهید.") %>
        <div class="space30"></div>
      """
    }
  end
end
