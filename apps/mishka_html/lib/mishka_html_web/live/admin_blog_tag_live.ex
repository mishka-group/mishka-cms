defmodule MishkaHtmlWeb.AdminBlogTagLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag
  @error_atom :blog_tag

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "مدیریت ساخت مجموعه",
        body_color: "#a29ac3cf",
        basic_menu: false,
        tags: [],
        editor: nil,
        id: nil,
        alias_link: nil,
        changeset: tag_changeset())
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case Tag.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->

        socket
        |> put_flash(:warning, "چنین برچسبی وجود ندارد یا ممکن است از قبل حذف شده باشد.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagsLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        tags = Enum.map(all_field, fn field ->
         record = Enum.find(creata_tag_state(repo_data), fn cat -> cat.type == field.type end)
         Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
        end)
        |> Enum.reject(fn x -> x.value == nil end)

        get_tag = Enum.find(tags, fn cat -> cat.type == "meta_keywords" end)


        socket
        |> assign([
          dynamic_form: tags,
          tags: if(is_nil(get_tag), do: [], else: if(is_nil(get_tag.value), do: [], else: String.split(get_tag.value, ","))),
          alias_link: repo_data.alias_link,
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
  def handle_event("save", %{"blog_tag" => params}, socket) do
    IO.inspect(params)
    case socket.assigns.id do
      nil -> create_tag(socket, params: {params})
      id ->  edit_tag(socket, params: {params, id})
    end
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", %{"_target" => ["blog_tag", type], "blog_tag" => params}, socket) when type not in ["main_image", "main_image"] do
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
        options_menu: false,
        alias_link: if(type == "title", do: MishkaHtml.create_alias_link(params["title"]), else: socket.assigns.alias_link),
        dynamic_form: new_dynamic_form
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("set_link", %{"key" => "Enter", "value" => value}, socket) do
    alias_link = MishkaHtml.create_alias_link(value)
    socket =
      socket
      |> assign(:alias_link, alias_link)
    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", _params, socket) do
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
        ])
    end

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("set_tag", %{"key" => "Enter", "value" => value}, socket) do
    new_socket = case Enum.any?(socket.assigns.tags, fn tag -> tag == value end) do
      true -> socket
      false ->
        socket
        |> assign([
          tags: [value] ++ socket.assigns.tags,
        ])
    end

    {:noreply, new_socket}
  end


  @impl true
  def handle_event("delete_tag", %{"tag" => value}, socket) do
    socket =
      socket
      |> assign(:tags, Enum.reject(socket.assigns.tags, fn tag -> tag == value end))
    {:noreply, socket}
  end

  @impl true
  def handle_event("basic_menu", _params, socket) do
    {:noreply, assign(socket, [basic_menu: !socket.assigns.basic_menu])}
  end

  @impl true
  def handle_event("make_all_basic_menu", _, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        options_menu: false,
        dynamic_form: socket.assigns.dynamic_form ++ create_menu_list(basic_menu_list(), socket.assigns.dynamic_form)
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_all_field", _, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        changeset: tag_changeset(),
        dynamic_form: []
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_form", %{"type" => type}, socket) do
    socket =
      socket
      |> assign([
        basic_menu: false,
        options_menu: false,
        dynamic_form: Enum.reject(socket.assigns.dynamic_form, fn x -> x.type == type end)
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogCategoriesLive"})
    {:noreply, socket}
  end

  defp create_tag(socket, params: {params}) do

    meta_keywords =
      MishkaHtml.list_tag_to_string(socket.assigns.tags, ", ")
      |> case do
        "" -> nil
        record -> record
      end

    case Tag.create(Map.merge(params, %{"meta_keywords" => meta_keywords, "alias_link" => socket.assigns.alias_link})) do
      {:error, :add, :blog_tag, repo_error} ->
        socket =
          socket
          |> assign([changeset: repo_error])
        {:noreply, socket}

      {:ok, :add, :blog_tag, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "برچسب: #{MishkaHtml.full_name_sanitize(repo_data.title)} درست شده است."})
        socket =
          socket
          |> put_flash(:info, "برچسب مورد نظر ساخته شد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagsLive))
        {:noreply, socket}
    end
  end

  defp edit_tag(socket, params: {params, id}) do
    meta_keywords =
      MishkaHtml.list_tag_to_string(socket.assigns.tags, ", ")
      |> case do
        "" -> nil
        record -> record
      end

    case Tag.edit(Map.merge(params, %{"id" => id, "meta_keywords" => meta_keywords, "alias_link" => socket.assigns.alias_link})) do
      {:error, :edit, :blog_tag, repo_error} ->

        socket =
          socket
          |> assign([
            changeset: repo_error,
          ])

        {:noreply, socket}

      {:ok, :edit, :blog_tag, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "برچسب: #{MishkaHtml.full_name_sanitize(repo_data.title)} به روز شده است."})

        socket =
          socket
          |> put_flash(:info, "برچسب به روز رسانی شد")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagsLive))

        {:noreply, socket}


      {:error, :edit, :uuid, _error_tag} ->
        socket =
          socket
          |> put_flash(:warning, "چنین برچسبی وجود ندارد یا ممکن است از قبل حذف شده باشد.")
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagsLive))

        {:noreply, socket}
    end
  end

  defp creata_tag_state(repo_data) do
    Map.drop(repo_data, [:inserted_at, :updated_at, :__meta__, :__struct__, :id, :blog_tags_mappers])
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

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{type: "title", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-4",
      title: "تیتر",
      description: "ساخت تیتر مناسب برای برچسب مورد نظر"},

      %{type: "custom_title", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-4",
      title: "تیتر سفارشی",
      description: "ساخت تیتر سفارشی مناسب برای برچسب مورد نظر"},

      %{type: "alias_link", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "convert_title_to_link",
      class: "col-sm-3",
      title: "لینک برچسب",
      description: "انتخاب لینک مجموعه برای ثبت و نمایش به کاربر. این فیلد یکتا می باشد."},

      %{type: "meta_keywords", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "add_tag",
      class: "col-sm-4",
      title: "کلمات کلیدی",
      description: "انتخاب چندین کلمه کلیدی برای ثبت بهتر مجموعه در موتور های جستجو."},

      %{type: "robots", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"},
        %{title: "هشدار", class: "badge bg-secondary"},
      ],
      options: [
        {"IndexFollow", :IndexFollow},
        {"IndexNoFollow", :IndexNoFollow},
        {"NoIndexFollow", :NoIndexFollow},
        {"NoIndexNoFollow", :NoIndexNoFollow},
      ],
      form: "select",
      class: "col-sm-2",
      title: "وضعیت رباط ها",
      description: " انتخاب دسترسی رباط ها برای ثبت محتوای داخل. لطفا در صورت نداشتن اطلاعات این فیلد را پر نکنید"},

      %{type: "meta_description", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "textarea",
      class: "col-sm-12",
      title: "توضیحات متا",
      description: "توضیحات خلاصه در مورد محتوا که حدود 200 کاراکتر می باشد."},


    ]
  end

  defp tag_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.BlogTag.changeset(
      %MishkaDatabase.Schema.MishkaContent.BlogTag{}, params
    )
  end
end