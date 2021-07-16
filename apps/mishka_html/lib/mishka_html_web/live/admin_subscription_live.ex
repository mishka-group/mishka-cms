defmodule MishkaHtmlWeb.AdminSubscriptionLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Subscription
  alias MishkaUser.User

  @error_atom :subscription

  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 10)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "ساخت یا ویرایش اشتراک",
        body_color: "#a29ac3cf",
        basic_menu: false,
        id: nil,
        user_search: [],
        changeset: subscription_changeset())
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case Subscription.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, "چنین اشتراکی وجود ندارد یا ممکن است از قبل حذف شده باشد.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSubscriptionsLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->
        user_info = Enum.map(all_field, fn field ->
         record = Enum.find(creata_subscription_state(repo_data), fn user -> user.type == field.type end)
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

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

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

  def handle_event("basic_menu", _params, socket) do
    {:noreply, assign(socket, [basic_menu: !socket.assigns.basic_menu, options_menu: false])}
  end

  def handle_event("make_all_basic_menu", _, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        dynamic_form: socket.assigns.dynamic_form ++ create_menu_list(basic_menu_list(), socket.assigns.dynamic_form)
      ])

    {:noreply, socket}
  end

  def handle_event("delete_form", %{"type" => type}, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        dynamic_form: Enum.reject(socket.assigns.dynamic_form, fn x -> x.type == type end)
      ])

    {:noreply, socket}
  end

  def handle_event("clear_all_field", _, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        changeset: subscription_changeset(),
        dynamic_form: []
      ])

    {:noreply, socket}
  end

  def handle_event("draft", %{"_target" => ["subscription", type], "subscription" => params}, socket) do
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
        user_search: if(type != "user_id", do: [], else: User.users(conditions: {1, 5}, filters: %{full_name: params["user_id"]}))
      ])

    {:noreply, socket}
  end

  def handle_event("draft", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"subscription" => params}, socket) do
    case socket.assigns.id do
      nil -> create_subscription(socket, params: {params})
      id ->  edit_subscription(socket, params: {params, id})
    end
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

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

  def handle_event("close_text_search", _, socket) do
    socket =
      socket
      |> assign([user_search: []])
    {:noreply, socket}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminSubscriptionLive"})
    {:noreply, socket}
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

  defp creata_subscription_state(repo_data) do
    Map.drop(repo_data, [:__struct__, :__meta__, :users, :id, :updated_at, :inserted_at, :extra, :expire_time])
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

  defp check_type_in_list(dynamic_form, new_item, type) do
    case Enum.any?(dynamic_form, fn x -> x.type == type end) do
      true ->

        {:error, :add_new_item_to_list, new_item}
      false ->

        {:ok, :add_new_item_to_list, add_new_item_to_list(dynamic_form, new_item)}
    end
  end

  defp subscription_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.Subscription.changeset(
      %MishkaDatabase.Schema.MishkaContent.Subscription{}, params
    )
  end

  defp add_new_item_to_list(dynamic_form, new_item) do
    List.insert_at(dynamic_form, -1, new_item)
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  defp create_subscription(socket, params: {params}) do
    case Subscription.create(params) do
      {:error, :add, :subscription, repo_error} ->
        socket =
          socket
          |> assign([changeset: repo_error])
        {:noreply, socket}

      {:ok, :add, :subscription, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "یک اشتراک برای بخش: #{repo_data.section} درست شده است."})

        socket =
          socket
          |> put_flash(:info, "اشتراک مورد نظر ساخته شد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSubscriptionsLive))
        {:noreply, socket}
    end
  end

  defp edit_subscription(socket, params: {params, id}) do

    case Subscription.edit(Map.merge(params, %{"id" => id})) do
      {:error, :edit, :subscription, repo_error} ->

        socket =
          socket
          |> assign([
            changeset: repo_error,
          ])

        {:noreply, socket}

      {:ok, :edit, :subscription, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "یک اشتراک از بهش: #{repo_data.section} به روز شده است."})

        socket =
          socket
          |> put_flash(:info, "اشتراک کاربر مورد نظر به روز رسانی شد")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSubscriptionsLive))

        {:noreply, socket}


      {:error, :edit, :uuid, _error_tag} ->
        socket =
          socket
          |> put_flash(:warning, "چنین اشتراکی وجود ندارد یا ممکن است از قبل حذف شده باشد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminSubscriptionsLive))

        {:noreply, socket}
    end
  end

  def basic_menu_list() do
    [
      %{type: "status", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      options: [
        {"غیر فعال", :inactive},
        {"فعال", :active},
        {"آرشیو شده", :archived},
        {"حذف با پرچم", :soft_delete},
      ],
      form: "select",
      class: "col-sm-4",
      title: "وضعیت",
      description: "وضعیت اشتراک کاربر نسبت به بخش انتخابی"},

      %{type: "section", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      options: [
        {"مطالب", :blog_post},
      ],
      form: "select",
      class: "col-sm-4",
      title: "بخش",
      description: "بخش مورد نظر اشتراک ثبت شده"},

      %{type: "section_id", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-3",
      title: "شناسه بخش",
      description: "شناسه بخش مورد نظر که باید اشتراک کاربر در آن ثبت گردد"},

      %{type: "expire_time", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"}
      ],
      form: "text",
      class: "col-sm-3",
      title: "انقضا",
      description: "با تعریف کردن انقضا شما می توانید اشتراک را برای مدت محدودی فعال نمایید."},

      %{type: "user_id", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text_search",
      class: "col-sm-3",
      title: "شناسه کاربر",
      description: "هر اشتراکی باید به یک کاربر تخصیص یابد."},
    ]
  end
end
