defmodule MishkaHtmlWeb.AdminUserLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.User
  @error_atom :user
  alias MishkaContent.Cache.ContentDraftManagement

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaUser.User,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminUserView, "admin_user_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "ساخت یا ویرایش کاربر"),
        body_color: "#a29ac3cf",
        basic_menu: false,
        id: nil,
        user_id: Map.get(session, "user_id"),
        drafts: ContentDraftManagement.drafts_by_section(section: "user"),
        draft_id: nil,
        changeset: user_changeset())
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case User.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین کاربری وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->
        user_info = Enum.map(all_field, fn field ->
         record = Enum.find(creata_user_state(repo_data), fn user -> user.type == field.type end)
         Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
        end)
        |> Enum.reject(fn x -> x.value == nil end)

        socket
        |> assign([
          dynamic_form: user_info,
          id: repo_data.id,
        ])
    end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # Live CRUD
  basic_menu()

  make_all_basic_menu()

  delete_form()

  clear_all_field(user_changeset())

  editor_draft("user", false, [], when_not: [])

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    # TODO: put flash msg should be imported to gettext
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
      nil -> create_user(socket, params: {params})
      id ->  edit_user(socket, params: {params, id})
    end
  end

  @impl true
  def handle_event("save", _params, socket) do
    # TODO: put flash msg should be imported to gettext
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


  selected_menue("MishkaHtmlWeb.AdminUserLive")


  defp user_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaUser.User.changeset(
      %MishkaDatabase.Schema.MishkaUser.User{}, params
    )
  end

  defp create_user(socket, params: {params}) do
    socket = case User.create(params) do
      {:error, :add, :user, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :user, repo_data} ->
        if(!is_nil(Map.get(socket.assigns, :draft_id)), do: MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id))
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "کاربر: %{title} درست شده است.", title: MishkaHtml.full_name_sanitize(repo_data.full_name))})
        MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "کاربر مورد نظر ساخته شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

    end

    {:noreply, socket}
  end

  defp edit_user(socket, params: {params, id}) do
    socket = case User.edit(Map.merge(params, %{"id" => id})) do
      {:error, :edit, :user, repo_error} ->
        socket
        |> assign([
          changeset: repo_error,
        ])

      {:ok, :edit, :user, repo_data} ->
        if(!is_nil(Map.get(socket.assigns, :draft_id)), do: MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id))
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "کاربر: %{title} به روز شده است.", title: MishkaHtml.full_name_sanitize(repo_data.full_name))})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "کاربر به روز رسانی شد"))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

      {:error, :edit, :uuid, _error_tag} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین کاربری وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

    end

    {:noreply, socket}
  end

  defp creata_user_state(repo_data) do
    Map.drop(repo_data, [:__struct__, :__meta__, :activities, :blog_likes, :bookmarks, :comments, :identities, :inserted_at, :updated_at, :notifs, :password_hash, :roles, :subscriptions, :users_roles, :id])
    |> Map.to_list()
    |> Enum.map(fn {key, value} ->
      IO.inspect(key)
      %{
        class: "#{search_fields(Atom.to_string(key)).class}",
        type: "#{Atom.to_string(key)}",
        value: value
      }
    end)
    |> Enum.reject(fn x -> x.value == nil end)
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{type: "full_name", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نام کامل"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "ساخت نام کامل کاربر")},


      %{type: "username", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "یکتا"), class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نام کاربری"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "ساخت نام کاربری کاربر که باید در سیستم یکتا باشد و پیرو قوانین ساخت سایت باشد")},

      %{type: "email", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "یکتا"), class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "ایمیل کاربر"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "ایمیل کاربر پایه و اساس شناسایی کاربر در سیستم می باشد و همینطور ایمیل برای هر حساب کاربری یکتا می باشد")},

      %{type: "status", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "ثب نام شده"), :registered},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), :active},
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), :inactive},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), :archived},
      ],
      form: "select",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت حساب کاربری")},

      %{type: "password", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"},
      ],
      form: "text",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "پسورد"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "پسورد و گذرواژه کاربر باید پیرو ساخت قوانین سیستم باشد و همینطور در بانک اطلاعاتی به صورت کد شده ذخیره سازی گردد")},

      %{type: "unconfirmed_email", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"},
      ],
      form: "text",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "ایمیل فعال سازی"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "ایمیل فعال سازی فیلدی می باشد که در صورت خالی بود یعنی حساب کاربر یک بار به وسیله ایمیل فعال سازی گردیده است. لطفا با وضعیت کاربر به صورت همزمان بررسی گردد.")},
    ]
  end
end
