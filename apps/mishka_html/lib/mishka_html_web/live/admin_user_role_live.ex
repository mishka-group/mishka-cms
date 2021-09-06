defmodule MishkaHtmlWeb.AdminUserRoleLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaUser.Acl.Role

  # TODO: change module
  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaUser.Acl.Role,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminUserView, "admin_user_role_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form:  create_menu_list(basic_menu_list(), []),
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "ساخت نقش"),
        body_color: "#a29ac3cf",
        basic_menu: false,
        changeset: role_changeset())
    {:ok, socket}
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
  def handle_event("draft", %{"_target" => ["role", type], "role" => params}, socket) do
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
  def handle_event("save", %{"role" => params}, socket) do
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

    socket = case Role.create(params) do
      {:error, :add, :role, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :role, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "نقش: %{title} درست شده است.", title: repo_data.name)})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "نقش مورد نظر ساخته شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUserRolesLive))

    end

    {:noreply, socket}
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

  selected_menue("MishkaHtmlWeb.AdminUserRoleLive")


  defp check_type_in_list(dynamic_form, new_item, type) do
    case Enum.any?(dynamic_form, fn x -> x.type == type end) do
      true ->

        {:error, :add_new_item_to_list, new_item}
      false ->

        {:ok, :add_new_item_to_list, List.insert_at(dynamic_form, -1, new_item)}
    end
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

  defp role_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaUser.Role.changeset(
      %MishkaDatabase.Schema.MishkaUser.Role{}, params
    )
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{type: "name", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "یکتا"), class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نام نقش"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "برای ایجاد هر دسترسی نیاز به معرفی نقش می باشد که هر نقش داری یک نام است")},

      %{type: "display_name", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "یکتا"), class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نام نمایشی"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "این فیلد نیز همانند نام هر نقش برای دسترسی ایجاد می شود و بیشتر برای شناسایی به کد شورت کد استفاده می گردد.")}
    ]
  end
end
