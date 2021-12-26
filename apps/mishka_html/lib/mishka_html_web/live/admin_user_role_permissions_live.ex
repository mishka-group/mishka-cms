defmodule MishkaHtmlWeb.AdminUserRolePermissionsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Acl.Permission
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت دسترسی ها")

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaUser.Acl.Permission,
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
        list={@permissions}
        url={MishkaHtmlWeb.AdminUserRolePermissionsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do:  Permission.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        filters: %{},
        page_size: 20,
        dynamic_form: [],
        page_title: @section_title,
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
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "این خطا در زمانی نمایش داده می شود که دسترسی مورد نظر شما از قبل وجود داشته باشد یا اشتباه باشد."))
        |> assign([changeset: repo_error])

      {:ok, :add, :permission, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "permission",
          section_id: repo_data.id,
          action: "add",
          priority: "high",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{user_action: "live_permission_create", type: "admin"})

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

  @impl true
  def handle_info(_params, socket) do
    {:noreply, socket}
  end

  defp permission_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaUser.Permission.changeset(
      %MishkaDatabase.Schema.MishkaUser.Permission{}, params
    )
  end

  def section_fields() do
    [
      ListItemComponent.text_field("value", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "دسترسی"),
      {true, false, false}),
      ListItemComponent.text_field("role_name", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "نام نقش"),
      {true, false, false}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.text_field("role_display_name", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "نام نمایش"),
      {true, false, false}, &MishkaHtml.username_sanitize/1),
      ListItemComponent.time_field("inserted_at", [1], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "ثبت"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برگشت به نقش ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminUserRolesLive),
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
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "دسترسی ها"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "دسترسی"),
        action: :section,
        action_by: :section,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "در این بخش شما امکان اضافه کردن نقش های مورد نیاز خود برای هر نقش را خواهید داشت. بعد از تخصیص هر دسترسی می توانید نقش را به یک کاربر متصل کنید") %>
        <div class="space30"></div>
        <div class="col-sm-12">
            <div class="clearfix"></div>
            <div class="space40"></div>
            <hr>
            <div class="space40"></div>
            <h3 class="admin-dashbord-h3-right-side-title vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "ایجاد دسترسی") %></h3>
            <.form let={f} for={@changeset}  phx-submit="save", multipart={true} >
                <div class="clearfix"></div>
                <div class="space30"></div>
                <div class="row vazir">

                    <div class="col-md-3">
                        <%= label f , MishkaTranslator.Gettext.dgettext("html_live_templates", "دسترسی") %>
                        <%= select f, :permission,
                            [
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "ویرایش"), :edit},
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "نمایش"), :view},
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "تمام دسترسی ها"), :*},
                            ],
                            class: "form-select"
                        %>
                    </div>

                    <div class="col-md-3">
                        <%= label f , "انتخاب بخش" %>
                        <%= select f, :section,
                            [
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "مطالب"), :blog},
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "نظرات"), :comment},
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "داشبورد مدیریت"), :admin},
                                {MishkaTranslator.Gettext.dgettext("html_live_templates", "تمام بخش ها"), :*}
                            ],
                            class: "form-select"
                        %>
                    </div>


                </div>

                <div class="space20"></div>
                <%= submit MishkaTranslator.Gettext.dgettext("html_live_templates", "اضافه کردن"), phx_disable_with: "Saving...", class: "btn btn-primary" %>
            </.form>
        </div>
      """
    }
  end
end
