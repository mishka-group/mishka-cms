defmodule MishkaHtmlWeb.AdminBlogNotifLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif, as: NotifSystem
  @error_atom :notif
  alias MishkaUser.User
  alias MishkaContent.Cache.ContentDraftManagement

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Notif,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    case assigns.render_type do
      :show -> Phoenix.View.render(MishkaHtmlWeb.AdminNotifView, "admin_notif_show_live.html", assigns)
      _ -> Phoenix.View.render(MishkaHtmlWeb.AdminNotifView, "admin_notif_live.html", assigns)
    end
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        render_type: :create,
        dynamic_form: [],
        body_color: "#a29ac3cf",
        basic_menu: false,
        options_menu: false,
        id: nil,
        editor: nil,
        user_id: Map.get(session, "user_id"),
        drafts: ContentDraftManagement.drafts_by_section(section: "notif"),
        draft_id: nil,
        user_search: [],
        changeset: notif_changeset(),
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اعلانات"),
        notif: nil
      )
      {:ok, socket}
  end

  def handle_params(%{"id" => id, "type" => "edit"}, _url, socket) do
    all_field = create_menu_list(basic_menu_list() ++ more_options_menu_list(), [])

    socket = case NotifSystem.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین اعلانی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifsLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        notif_forms = Enum.map(all_field, fn field ->
          record = Enum.find(creata_notif_state(repo_data), fn notif -> notif.type == field.type end)
          Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
         end)
         |> Enum.reject(fn x -> x.value == nil end)

         description =
          Enum.find(notif_forms, fn notif -> notif.type == "description" end) || %{value: ""}

         socket
         |> assign([
           dynamic_form: notif_forms,
           id: repo_data.id,
           render_type: :edit,
           editor: repo_data.description
         ])
         |> push_event("update-editor-html", %{html: description.value})
    end

    {:noreply, socket}
  end

  def handle_params(%{"id" => id, "type" => "show"}, _url, socket) do
    socket = case NotifSystem.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین اعلانی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifsLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        socket
        |> assign(
          render_type: :show,
          notif: repo_data
        )
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

  editor_draft("notif", true, [
    {:user_search, :return_params,
      fn type, params  ->
        if(type != "user_id", do: [], else: User.users(conditions: {1, 5}, filters: %{full_name: Map.get(params, ["user_id"])}))
      end
    }
  ], when_not: [])

  @impl true
  def handle_event("save", %{"notif" => params}, socket) do
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

    case socket.assigns.id do
      nil -> create_notif(socket, params: {Map.merge(params, %{"description" => socket.assigns.editor})})
      id -> edit_category(socket, params: {Map.merge(params, %{"id" => id, "description" => socket.assigns.editor})})
    end

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

  @impl true
  def handle_event("text_search_click", %{"id" => id}, socket) do
    new_dynamic_form = Enum.map(socket.assigns.dynamic_form, fn x ->
      case x.type do
        "user_id" -> Map.merge(x, %{value: id})
        _ -> x
      end
    end)

    socket =
      socket
      |> assign([
        dynamic_form: new_dynamic_form,
        user_search: []
      ])
      |> push_event("update_text_search", %{value: id})



    {:noreply, socket}
  end

  @impl true
  def handle_event("close_text_search", _, socket) do
    socket =
      socket
      |> assign([user_search: []])
    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogNotifLive")

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp creata_notif_state(repo_data) do
    Map.drop(repo_data, [:inserted_at, :updated_at, :__meta__, :__struct__, :users, :id, :extra, :user_notif_statuses])
    |> Map.to_list()
    |> Enum.map(fn {key, value} ->
      %{
        class: "#{search_fields(Atom.to_string(key)).class}",
        type: "#{Atom.to_string(key)}",
        value: value
      }
    end)
    |> Enum.reject(fn x -> x.value == nil end)
  end

  defp notif_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.Notif.changeset(
      %MishkaDatabase.Schema.MishkaContent.Notif{}, params
    )
  end

  defp create_notif(socket, params: {params}) do
    socket = case NotifSystem.create(params) do
      {:error, :add, :notif, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :notif, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "notif",
          section_id: repo_data.id,
          action: "add",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{full_name: Map.get(repo_data, :full_name)})

        if(!is_nil(Map.get(socket.assigns, :draft_id)), do: MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id))
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "اعلان: %{title} درست شده است.", title: MishkaHtml.title_sanitize(repo_data.title))})

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "اعلان مورد نظر ارسال شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifsLive))

    end

    {:noreply, socket}
  end


  def edit_category(socket, params: {params}) do
    socket = case NotifSystem.edit(params) do
      {:error, :edit, @error_atom, repo_error} ->
        socket
        |> assign([
          changeset: repo_error,
        ])

      {:ok, :edit, @error_atom, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "notif",
          section_id: repo_data.id,
          action: "edit",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{})

        if(!is_nil(Map.get(socket.assigns, :draft_id)), do: MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id))

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "اعلان به روز رسانی شد"))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifsLive))

      {:error, :edit, :uuid, _error_tag} ->

        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین اعلان وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifsLive))

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

      %{type: "description", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      form: "editor",
      class: "col-sm-12",
      title: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات کامل"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات کامل اعلان")},
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

      %{type: "user_id", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"}
      ],
      form: "text_search",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نام کاربری"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "به واسطه این فیلد می توانید کاربر مورد نظر خود را به یک اعلان تخصیص بدهید")},

      # TODO: add extra like dynamic form
      # TODO: create a time form
      # TODO: fix mobile css for client notif
    ]
  end
end
