defmodule MishkaHtmlWeb.AdminSettingLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaDatabase.Schema.Public.Setting, as: SettingSchema
  alias MishkaDatabase.Public.Setting
  @error_atom :setting

  # TODO: change module
  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaDatabase.Public.Setting,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminSettingView, "admin_setting_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "ویرایش و اضافه کردن تنظیمات"),
        body_color: "#a29ac3cf",
        basic_menu: false,
        id: nil,
        user_id: Map.get(session, "user_id"),
        draft_id: nil,
        configs: [{"", ""}],
        draft_state: [],
        changeset: setting_changeset())

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case Setting.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین نمظیماتی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSettingsLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        user_info = Enum.map(all_field, fn field ->
         record = Enum.find(creata_setting_state(repo_data), fn user -> user.type == field.type end)
         Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
        end)
        |> Enum.reject(fn x -> x.value == nil end)

        draft_state = repo_data.configs
        |> Map.to_list()
        |> Enum.with_index(fn element, index -> {index, element} end)
        |> Enum.map(fn {item, {field, value}} ->
          [
            {"input-name-#{item + 1}", field},
            {"input-value-#{item + 1}", value}
          ]
        end)
        |> Enum.concat()

        socket
        |> assign([
          dynamic_form: user_info,
          id: repo_data.id,
          configs: Map.to_list(repo_data.configs),
          draft_state: draft_state
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

  clear_all_field(setting_changeset())

  @impl true
  def handle_event("delete_user_form", %{"id" => id}, socket) do

    user_fields = socket.assigns.draft_state
    |> Enum.reject(fn {key, _value} -> key == id end)
    |> Enum.filter(fn {key, _value} -> String.slice(key, 0..5) == "input-" end)

    configs = create_configs(user_fields, :list)

    draft_state = configs
    |> Map.to_list()
    |> Enum.with_index(fn element, index -> {index, element} end)
    |> Enum.map(fn {item, {field, value}} ->
      [
        {"input-name-#{item + 1}", field},
        {"input-value-#{item + 1}", value}
      ]
    end)
    |> Enum.concat()


    socket =
      socket
      |> assign(draft_state: draft_state, configs: configs |> Map.to_list)

    {:noreply, socket}
  end


  @impl true
  def handle_event("draft", params, socket) do
    configs = params
    |> Map.drop(["setting", "_target", "_csrf_token"])

    socket =
      socket
      |> assign(draft_state: configs)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_field", _params, socket) do
    {:noreply, assign(socket, configs: socket.assigns.configs ++ [{"", ""}])}
  end

  @impl true
  def handle_event("save", %{"setting" => params} = full_params, socket) do
    configs = if(create_configs(full_params, :map) != %{}, do: create_configs(full_params, :map), else: nil)
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
      nil -> create_setting(socket, params: {Map.merge(params, %{"configs" => configs})})
      id ->  edit_setting(socket, params: {Map.merge(params, %{"configs" => configs}), id})
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


  selected_menue("MishkaHtmlWeb.AdminSettingLive")

  defp create_configs(params, :list) do
    params
    |> create_configs()
  end

  defp create_configs(params, :map) do
    Map.to_list(params)
    |> create_configs()
  end

  defp create_configs(params) do
    user_fields =
    params
    |> Enum.filter(fn {key, _value} -> String.slice(key, 0..5) == "input-" end)

    Enum.map(user_fields, fn {key, field_name} ->
      if String.slice(key, 0..10) == "input-name-" do
        ["input", "name", number] = String.split(key, "-")
        {_value_key, value_value} = Enum.find(user_fields, fn {user_key, _user_value} -> user_key == "input-value-#{number}" end)
        {field_name, value_value}
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(fn {key, value} -> key == "" or value == "" end)
    |> Map.new
  end

  defp create_setting(socket, params: {params}) do
    socket = case Setting.create(params) do
      {:error, :add, :setting, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :setting, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "setting",
          section_id: repo_data.id,
          action: "add",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        })

        if(!is_nil(Map.get(socket.assigns, :draft_id)), do: MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id))
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات بخش: %{title} درست شده است.", title: MishkaHtml.full_name_sanitize(repo_data.section))})

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات مورد نظر ساخته شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSettingsLive))

    end

    {:noreply, socket}
  end


  defp edit_setting(socket, params: {params, id}) do
    socket = case Setting.edit(Map.merge(params, %{"id" => id})) do
      {:error, :edit, :setting, repo_error} ->
        socket
        |> assign([
          changeset: repo_error,
        ])

      {:ok, :edit, :setting, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "setting",
          section_id: repo_data.id,
          action: "edit",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        })

        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات بخش: %{title} به روز شده است.", title: MishkaHtml.full_name_sanitize(repo_data.section))})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات مورد نظر به روز رسانی شد"))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSettingsLive))

      {:error, :edit, :uuid, _error_tag} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین تنظیماتی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSettingsLive))

    end

    {:noreply, socket}
  end

  defp setting_changeset(params \\ %{}) do
    SettingSchema.changeset(
      %SettingSchema{}, params
    )
  end

  defp creata_setting_state(repo_data) do
    Map.drop(repo_data, [:__struct__, :__meta__, :inserted_at, :updated_at, :id])
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

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{type: "section", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات عمومی"), :public},
      ],
      form: "select",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "بخش"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "شما برای هر بخش از سایت می توانید فقط یک تنظیمات وارد کنید.")},

      %{type: "configs", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      form: "add_field",
      class: "col-sm-4",
      title: MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "شما در این بخش می توانید تنظیماتی که می خواهید را با اسم سفارشی خودتان وارد کنید. لازم به ذکر هست از تغییر اسم تنظیمات پیشفرض که موقع نصب به سیستم شما خودکار اضافه شدن به شدت پرهیز کنید.")},
    ]
  end
end
