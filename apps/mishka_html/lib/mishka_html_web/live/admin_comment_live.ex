defmodule MishkaHtmlWeb.AdminCommentLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Comment
  @error_atom :comment

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "مدیریت ویرایش نظر",
        basic_menu: false,
        id: nil,
        user_search: [],
        changeset: comment_changeset())
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case Comment.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->

        socket
        |> put_flash(:warning, "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        comment = Enum.map(all_field, fn field ->
         record = Enum.find(creata_comment_state(repo_data), fn cat -> cat.type == field.type end)
         Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
        end)
        |> Enum.reject(fn x -> x.value == nil end)

        description = Enum.find(comment, fn cm -> cm.type == "description" end)

        socket
        |> assign([
          dynamic_form: comment,
          id: repo_data.id,
        ])
        |> push_event("update-editor-html", %{html: description.value})
    end

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    socket
    |> put_flash(:warning, "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد.")
    |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))
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
        changeset: comment_changeset(),
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

  def handle_event("draft", params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"comment" => params}, socket) do
    case Comment.edit(Map.merge(params, %{"id" => socket.assigns.id})) do
      {:error, :edit, @error_atom, repo_error} ->
        socket =
          socket
          |> assign([
            changeset: repo_error,
          ])

        {:noreply, socket}

      {:ok, :edit, @error_atom, repo_data} ->
        socket =
          socket
          |> put_flash(:info, "نظر به روز رسانی شد")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

        {:noreply, socket}


      {:error, :edit, :uuid, _error_tag} ->
        socket =
          socket
          |> put_flash(:warning, "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

        {:noreply, socket}
    end
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end


  defp creata_comment_state(repo_data) do
    Map.drop(repo_data, [:inserted_at, :updated_at, :__meta__, :__struct__, :users, :id, :comments_likes])
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

  defp comment_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.Comment.changeset(
      %MishkaDatabase.Schema.MishkaContent.Comment{}, params
    )
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  defp add_new_item_to_list(dynamic_form, new_item) do
    List.insert_at(dynamic_form, -1, new_item)
  end

  defp check_type_in_list(dynamic_form, new_item, type) do
    case Enum.any?(dynamic_form, fn x -> x.type == type end) do
      true ->

        {:error, :add_new_item_to_list, new_item}
      false ->

        {:ok, :add_new_item_to_list, add_new_item_to_list(dynamic_form, new_item)}
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
        description: "وضعیت نظر ارسالی از طرف کاربر"},


        %{type: "priority", status: [
          %{title: "ضروری", class: "badge bg-danger"}
        ],
        options: [
          {"بدون اولویت", :none},
          {"پایین", :low},
          {"متوسط", :medium},
          {"بالا", :high},
          {"ویژه", :featured}
        ],
        form: "select",
        class: "col-sm-4",
        title: "اولویت",
        description: "اولیت نظر ارسالی"},

        %{type: "section", status: [
          %{title: "ضروری", class: "badge bg-danger"}
        ],
        options: [
          {"مطالب", :blog_post},
        ],
        form: "select",
        class: "col-sm-4",
        title: "بخش",
        description: "بخش تخصیص یافته به نظر"},

        %{type: "section_id", status: [
          %{title: "ضروری", class: "badge bg-danger"}
        ],
        form: "text",
        class: "col-sm-3",
        title: "شناسه بخش",
        description: "شناسه بخش تخصیص یافته به نظر ارسالی"},

        %{type: "sub", status: [
          %{title: "ضروری", class: "badge bg-danger"}
        ],
        form: "text",
        class: "col-sm-3",
        title: "شناسه نظر",
        description: "شناسه بخش تخصیص یافته به نظر ارسالی"},

        %{type: "user_id", status: [
          %{title: "ضروری", class: "badge bg-danger"}
        ],
        form: "text",
        class: "col-sm-3",
        title: "شناسه کاربر",
        description: "هر نظر باید به یک کاربر تخصیص پیدا کند."},

        %{type: "description", status: [
          %{title: "ضروری", class: "badge bg-danger"}
        ],
        form: "textarea",
        class: "col-sm-12",
        title: "توضیحات",
        description: "نظر ارسالی از طرف کاربر"},
      ]
  end
end
