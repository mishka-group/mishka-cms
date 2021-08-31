defmodule MishkaHtmlWeb.AdminSettingLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaDatabase.Schema.Public.Setting, as: SettingSchema
  alias MishkaDatabase.Public.Setting
  @error_atom :setting

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminSettingView, "admin_setting_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "ویرایش و اضافه کردن تنظیمات"),
        body_color: "#a29ac3cf",
        basic_menu: false,
        id: nil,
        configs: 1,
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

  @impl true
  def handle_event("basic_menu", %{"type" => type, "class" => class}, socket) do
    new_socket = case check_type_in_list(socket.assigns.dynamic_form, %{type: type, value: nil, class: class}, type) do
      {:ok, :add_new_item_to_list, _new_item} ->

        assign(socket, [
          basic_menu: !socket.assigns.basic_menu,
          dynamic_form:  socket.assigns.dynamic_form ++ [%{type: type, value: nil, class: class}]
        ])

      {:error, :add_new_item_to_list, _new_item} ->
        assign(socket, [
          basic_menu: !socket.assigns.basic_menu,
          options_menu: false
        ])
    end

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("basic_menu", _params, socket) do
    {:noreply, assign(socket, [basic_menu: !socket.assigns.basic_menu, options_menu: false])}
  end


  @impl true
  def handle_event("make_all_basic_menu", _, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        dynamic_form: socket.assigns.dynamic_form ++ create_menu_list(basic_menu_list(), socket.assigns.dynamic_form)
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_form", %{"type" => type}, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        dynamic_form: Enum.reject(socket.assigns.dynamic_form, fn x -> x.type == type end)
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_all_field", _, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        changeset: setting_changeset(),
        dynamic_form: [],
        configs: 1
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", %{"_target" => ["user", type], "user" => params}, socket) do
    # save in genserver

    {_key, value} = Map.take(params, [type])
    |> Map.to_list()
    |> List.first()


    new_dynamic_form = Enum.map(socket.assigns.dynamic_form, fn x ->
      if x.type == type, do: Map.merge(x, %{value: value}), else: x
    end)

    socket =
      socket
      |> assign([
        basic_menu: false,
        dynamic_form: new_dynamic_form,
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_field", _params, socket) do
    {:noreply, assign(socket, configs: socket.assigns.configs + 1)}
  end

  @impl true
  def handle_event("save", %{"setting" => params} = full_params, socket) do
    configs = if(create_configs(full_params) != %{}, do: create_configs(full_params), else: nil)
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
      id ->  edit_setting(socket, params: {params, id})
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

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminSettingLive"})
    {:noreply, socket}
  end

  defp create_configs(params) do
    user_fields = Map.to_list(params)
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

  defp create_menu_list(menus_list, dynamic_form) do
    Enum.map(menus_list, fn menu ->
      case check_type_in_list(dynamic_form, %{type: menu.type, value: nil, class: menu.class}, menu.type) do
        {:ok, :add_new_item_to_list, _new_item} ->

          %{type: menu.type, value: nil, class: menu.class}

        {:error, :add_new_item_to_list, _new_item} -> nil
      end
    end)
    |> Enum.reject(fn x -> x == nil end)
  end

  defp check_type_in_list(dynamic_form, new_item, type) do
    case Enum.any?(dynamic_form, fn x -> x.type == type end) do
      true ->

        {:error, :add_new_item_to_list, new_item}
      false ->

        {:ok, :add_new_item_to_list, add_new_item_to_list(dynamic_form, new_item)}
    end
  end

  defp add_new_item_to_list(dynamic_form, new_item) do
    List.insert_at(dynamic_form, -1, new_item)
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
