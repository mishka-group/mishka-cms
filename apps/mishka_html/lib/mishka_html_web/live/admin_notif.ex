defmodule MishkaHtmlWeb.AdminBlogNotifLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif, as: NotifSystem
  @error_atom :notif
  alias MishkaContent.Cache.ContentDraftManagement

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Notif,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminNotifView, "admin_notif_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        body_color: "#a29ac3cf",
        basic_menu: false,
        options_menu: false,
        id: nil,
        user_id: Map.get(session, "user_id"),
        drafts: ContentDraftManagement.drafts_by_section(section: "user"),
        draft_id: nil,
        changeset: notif_changeset(),
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اعلانات")
      )
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    socket = case NotifSystem.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین اعلانی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

      {:ok, :get_record_by_id, @error_atom, _repo_data} ->

        # TODO: show data with extra in a page like activity admin show
        socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # Live CRUD
  basic_menu()

  options_menu()

  save_editor("notif")

  delete_form()

  make_all_basic_menu()

  clear_all_field(notif_changeset())

  make_all_menu()

  editor_draft("notif", false, [], when_not: [])

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    socket = case MishkaHtml.html_form_required_fields(basic_menu_list(), params) do
      [] -> socket
      fields_list ->

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "
        متاسفانه شما چند فیلد ضروری را به لیست خود اضافه نکردید از جمله:
         (%{list_tag})
         برای اضافه کردن تمامی نیازمندی ها روی دکمه
         \"فیلد های ضروری\"
          کلیک کنید
         ", list_tag: MishkaHtml.list_tag_to_string(fields_list, ", ")))
    end

    create_notif(socket, params: {params})
  end

  @impl true
  def handle_event("save", _params, socket) do
    socket = case MishkaHtml.html_form_required_fields(basic_menu_list(), []) do
      [] -> socket
      fields_list ->

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "
        متاسفانه شما چند فیلد ضروری را به لیست خود اضافه نکردید از جمله:
         (%{list_tag})
         برای اضافه کردن تمامی نیازمندی ها روی دکمه
         \"فیلد های ضروری\"
          کلیک کنید
         ", list_tag: MishkaHtml.list_tag_to_string(fields_list, ", ")))
    end
    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogNotifLive")

  defp notif_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.Notif.changeset(
      %MishkaDatabase.Schema.MishkaContent.Notif{}, params
    )
  end

  defp create_notif(socket, params: {params}) do
    socket = case NotifSystem.create(params) do
      {:error, :add, :user, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :user, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "user",
          section_id: repo_data.id,
          action: "add",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{full_name: Map.get(repo_data, :full_name)})

        if(!is_nil(Map.get(socket.assigns, :draft_id)), do: MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id))
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "کاربر: %{title} درست شده است.", title: MishkaHtml.full_name_sanitize(repo_data.full_name))})
        MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "اعلان مورد نظر ارسال شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

    end

    {:noreply, socket}
  end

  def search_fields(type) do
    Enum.find(basic_menu_list() ++ more_options_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{type: "title", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "تیتر اعلان"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "فیلد نمایش تیتر اعلان")},


      %{type: "status", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), :inactive},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), :active},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), :archived},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), :soft_delete},
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت اعلان")},

      %{type: "section", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "مطلب بلاگ"), :blog_post},
        {MishkaTranslator.Gettext.dgettext("html_live", "مدیریت"), :admin},
        {MishkaTranslator.Gettext.dgettext("html_live", "تخصیص به یک کاربر"), :user_only},
        {MishkaTranslator.Gettext.dgettext("html_live", "عمومی/انبوه"), :public},
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "بخش"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "بخش تخصیص اعلان")},

      %{type: "type", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "کاربری"), :client},
        {MishkaTranslator.Gettext.dgettext("html_live", "مدیریتی"), :admin}
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نوع"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "نوع تخصیص اعلان")},

      %{type: "target", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "همه"), :all},
        {MishkaTranslator.Gettext.dgettext("html_live", "موبایل"), :mobile},
        {MishkaTranslator.Gettext.dgettext("html_live", "android"), :android},
        {MishkaTranslator.Gettext.dgettext("html_live", "ios"), :ios},
        {MishkaTranslator.Gettext.dgettext("html_live", "cli"), :cli},
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "هدف"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "هدف اعلان")},
    ]
  end

  def more_options_menu_list() do
    [

      %{type: "section_id", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "شناسه بخش"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "برای اتصال به یک بخش یکتا استفاده می گردد")},

      %{type: "expire_time", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر پیشنهادی"), class: "badge bg-warning"}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "تاریخ انقضا"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "شما به واسطه این فیلد می توانید تاریخ انقضا برای یک اعلان را مشخص کنید.")},

      %{type: "description", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "پیشنهادی"), class: "badge bg-dark"}
      ],
      form: "editor",
      class: "col-sm-12",
      title: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات کامل"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات کامل اعلان")},

      # TODO: add extra like dynamic form
      # TODO: add user search field
      # TODO: create a time form
    ]
  end
end
