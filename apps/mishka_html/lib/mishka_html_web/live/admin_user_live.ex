defmodule MishkaHtmlWeb.AdminUserLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.User
  @error_atom :user

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "ساخت یا ویرایش کاربر",
        body_color: "#a29ac3cf",
        basic_menu: false,
        id: nil,
        changeset: user_changeset())
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case User.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->
        socket
        |> put_flash(:warning, "چنین کاربری وجود ندارد یا ممکن است از قبل حذف شده باشد.")
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
        changeset: user_changeset(),
        dynamic_form: []
      ])

    {:noreply, socket}
  end

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

  def handle_event("draft", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    case socket.assigns.id do
      nil -> create_user(socket, params: {params})
      id ->  edit_user(socket, params: {params, id})
    end
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  defp user_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaUser.User.changeset(
      %MishkaDatabase.Schema.MishkaUser.User{}, params
    )
  end

  defp create_user(socket, params: {params}) do
    case User.create(params) do
      {:error, :add, :user, repo_error} ->
        socket =
          socket
          |> assign([changeset: repo_error])
        {:noreply, socket}

      {:ok, :add, :user, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "کاربر: #{repo_data.full_name} درست شده است."})
        MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})
        socket =
          socket
          |> put_flash(:info, "کاربر مورد نظر ساخته شد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))
        {:noreply, socket}
    end
  end

  defp edit_user(socket, params: {params, id}) do

    case User.edit(Map.merge(params, %{"id" => id})) do
      {:error, :edit, :user, repo_error} ->

        socket =
          socket
          |> assign([
            changeset: repo_error,
          ])

        {:noreply, socket}

      {:ok, :edit, :user, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "کاربر: #{repo_data.full_name} به روز شده است."})

        socket =
          socket
          |> put_flash(:info, "کاربر به روز رسانی شد")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

        {:noreply, socket}


      {:error, :edit, :uuid, _error_tag} ->
        socket =
          socket
          |> put_flash(:warning, "چنین کاربری وجود ندارد یا ممکن است از قبل حذف شده باشد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminUsersLive))

        {:noreply, socket}
    end
  end

  defp creata_user_state(repo_data) do
    Map.drop(repo_data, [:__struct__, :__meta__, :blog_likes, :bookmarks, :comments, :identities, :inserted_at, :updated_at, :notifs, :password_hash, :roles, :subscriptions, :users_roles, :id])
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

  defp add_new_item_to_list(dynamic_form, new_item) do
    List.insert_at(dynamic_form, -1, new_item)
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{type: "full_name", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-4",
      title: "نام کامل",
      description: "ساخت نام کامل کاربر"},


      %{type: "username", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-4",
      title: "نام کاربری",
      description: "ساخت نام کاربری کاربر که باید در سیستم یکتا باشد و پیرو قوانین ساخت سایت باشد"},

      %{type: "email", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "text",
      class: "col-sm-4",
      title: "ایمیل کاربر",
      description: "ایمیل کاربر پایه و اساس شناسایی کاربر در سیستم می باشد و همینطور ایمیل برای هر حساب کاربری یکتا می باشد"},

      %{type: "status", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      options: [
        {"ثب نام شده", :registered},
        {"فعال", :active},
        {"غیر فعال", :inactive},
        {"آرشیو شده", :archived},
      ],
      form: "select",
      class: "col-sm-4",
      title: "وضعیت",
      description: "وضعیت حساب کاربری"},

      %{type: "password", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "text",
      class: "col-sm-4",
      title: "پسورد",
      description: "پسورد و گذرواژه کاربر باید پیرو ساخت قوانین سیستم باشد و همینطور در بانک اطلاعاتی به صورت کد شده ذخیره سازی گردد"},

      %{type: "unconfirmed_email", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "text",
      class: "col-sm-4",
      title: "ایمیل فعال سازی",
      description: "ایمیل فعال سازی فیلدی می باشد که در صورت خالی بود یعنی حساب کاربر یک بار به وسیله ایمیل فعال سازی گردیده است. لطفا با وضعیت کاربر به صورت همزمان بررسی گردد."},
    ]
  end
end
