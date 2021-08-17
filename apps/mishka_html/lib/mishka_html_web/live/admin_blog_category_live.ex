defmodule MishkaHtmlWeb.AdminBlogCategoryLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  @error_atom :category

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_category_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "مدیریت ساخت مجموعه",
        body_color: "#a29ac3cf",
        basic_menu: false,
        options_menu: false,
        tags: [],
        editor: nil,
        id: nil,
        images: {nil, nil},
        alias_link: nil,
        category_search: [],
        sub: nil,
        changeset: category_changeset())
        |> assign(:uploaded_files, [])
        |> allow_upload(:main_image_upload, accept: ~w(.jpg .jpeg .png), max_entries: 1, max_file_size: 10_000_000, auto_upload: true)
        |> allow_upload(:header_image_upload, accept: ~w(.jpg .jpeg .png), max_entries: 1, max_file_size: 10_000_000, auto_upload: true)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list() ++ more_options_menu_list(), [])

    socket = case Category.show_by_id(id) do
      {:error, :get_record_by_id, @error_atom} ->

        socket
        |> put_flash(:warning, "چنین مجموعه ای وجود ندارد یا ممکن است از قبل حذف شده باشد.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        categories = Enum.map(all_field, fn field ->
         record = Enum.find(creata_category_state(repo_data), fn cat -> cat.type == field.type end)
         Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
        end)
        |> Enum.reject(fn x -> x.value == nil end)


        get_tag = Enum.find(categories, fn cat -> cat.type == "meta_keywords" end)
        description = Enum.find(categories, fn cat -> cat.type == "description" end)


        socket
        |> assign([
          dynamic_form: categories,
          tags: if(is_nil(get_tag), do: [], else: if(is_nil(get_tag.value), do: [], else: String.split(get_tag.value, ","))),
          id: repo_data.id,
          images: {repo_data.main_image, repo_data.header_image},
          alias_link: repo_data.alias_link,
          sub: repo_data.sub
        ])
        |> push_event("update-editor-html", %{html: description.value})
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
          options_menu: false,
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
  def handle_event("options_menu", %{"type" => type, "class" => class}, socket) do
    new_socket = case check_type_in_list(socket.assigns.dynamic_form, %{type: type, value: nil, class: class}, type) do
      {:ok, :add_new_item_to_list, _new_item} ->

        assign(socket, [
          basic_menu: false,
          options_menu: !socket.assigns.options_menu,
          dynamic_form: socket.assigns.dynamic_form ++ [%{type: type, value: nil, class: class}]
        ])

      {:error, :add_new_item_to_list, _new_item} ->
        assign(socket, [
          basic_menu: false,
          options_menu: !socket.assigns.options_menu,
        ])
    end

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("options_menu", _params, socket) do
    {:noreply, assign(socket, [basic_menu: false, options_menu: !socket.assigns.options_menu])}
  end

  @impl true
  def handle_event("save", %{"category" => params}, socket) do
    # TODO: put flash msg should be imported to gettext
    socket = case MishkaHtml.html_form_required_fields(basic_menu_list(), params) do
      [] -> socket
      fields_list ->

        socket
        |> put_flash(:info, "
        متاسفانه شما چند فیلد ضروری را به لیست خود اضافه نکردید از جمله:
         (#{MishkaHtml.list_tag_to_string(fields_list, ", ")})
         برای اضافه کردن تمامی نیازمندی ها روی دکمه
         \"فیلد های ضروری\"
          کلیک کنید
         ")
    end


    uploaded_main_image_files = upload(socket, :main_image_upload)
    uploaded_header_image_files = upload(socket, :header_image_upload)

    meta_keywords = MishkaHtml.list_tag_to_string(socket.assigns.tags, ", ")

    case socket.assigns.id do
      nil ->
        create_category(socket, params: {
          params,
          if(meta_keywords == "", do: nil, else: meta_keywords),
          if(uploaded_main_image_files != [], do: List.first(uploaded_main_image_files), else: nil),
          if(uploaded_header_image_files != [], do: List.first(uploaded_header_image_files), else: nil),
          if(is_nil(socket.assigns.editor), do: nil, else: socket.assigns.editor),
          socket.assigns.alias_link,
          socket.assigns.sub
        },
        uploads: {uploaded_main_image_files, uploaded_header_image_files})
      id ->

        edit_category(socket, params: {
          params,
          if(meta_keywords == "", do: nil, else: meta_keywords),
          if(uploaded_main_image_files != [], do: List.first(uploaded_main_image_files), else: nil),
          if(uploaded_header_image_files != [], do: List.first(uploaded_header_image_files), else: nil),
          if(is_nil(socket.assigns.editor), do: nil, else: socket.assigns.editor),
          id,
          socket.assigns.alias_link,
          socket.assigns.sub
        },
        uploads: {uploaded_main_image_files, uploaded_header_image_files})

    end
  end

  @impl true
  def handle_event("save", _params, socket) do
    # TODO: put flash msg should be imported to gettext
    socket = case MishkaHtml.html_form_required_fields(basic_menu_list(), []) do
      [] -> socket
      fields_list ->

        socket
        |> put_flash(:info, "
        متاسفانه شما چند فیلد ضروری را به لیست خود اضافه نکردید از جمله:
         (#{MishkaHtml.list_tag_to_string(fields_list, ", ")})
         برای اضافه کردن تمامی نیازمندی ها روی دکمه
         \"فیلد های ضروری\"
          کلیک کنید
         ")
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("save-editor", %{"html" => params}, socket) do
    socket =
      socket
      |> assign([editor: params])
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
        changeset: category_changeset(),
        options_menu: false,
        dynamic_form: []
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("make_all_menu", _, socket) do
    fields = create_menu_list(basic_menu_list() ++ more_options_menu_list(), socket.assigns.dynamic_form)

    socket =
      socket
      |> assign([
        basic_menu: false,
        options_menu: false,
        dynamic_form: socket.assigns.dynamic_form ++ fields
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("text_search_click", %{"id" => id}, socket) do
    socket =
      socket
      |> assign([
        sub: id,
        category_search: []
      ])
      |> push_event("update_text_search", %{value: id})

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_text_search", _, socket) do
    socket =
      socket
      |> assign([category_search: []])
    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", %{"_target" => ["category", type], "category" => params}, socket) when type not in ["main_image", "main_image"] do
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
        dynamic_form: new_dynamic_form,
        alias_link: if(type == "title", do: MishkaHtml.create_alias_link(params["title"]), else: socket.assigns.alias_link),
        category_search: Category.search_category_title(params["sub"], 5)
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("draft", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "upload_field" => field} = _params, socket) do
    {:noreply, cancel_upload(socket, String.to_atom(field), ref)}
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
  def handle_event("set_link", %{"key" => "Enter", "value" => value}, socket) do
    alias_link = MishkaHtml.create_alias_link(value)
    socket =
      socket
      |> assign(:alias_link, alias_link)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_image", %{"type" => type}, socket) do
    {main_image, header_image} = socket.assigns.images

    image = if(type == "main_image", do: main_image, else: header_image)

    Path.join([:code.priv_dir(:mishka_html), "static", image])
    |> File.rm()

    socket =
      socket
      |> assign(:images, if(type == "main_image", do: {nil, header_image} , else: {main_image, nil}))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogCategoryLive"})
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

  def search_fields(type) do
    Enum.find(basic_menu_list() ++ more_options_menu_list(), fn x -> x.type == type end)
  end

  defp upload(socket, upload_id) do
    consume_uploaded_entries(socket, upload_id, fn %{path: path}, entry ->
      dest = Path.join([:code.priv_dir(:mishka_html), "static", "uploads", file_name(entry)])
      File.cp!(path, dest)
      Routes.static_path(socket, "/uploads/#{file_name(entry)}")
    end)
  end

  defp file_name(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  defp category_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.Blog.Category.changeset(
      %MishkaDatabase.Schema.MishkaContent.Blog.Category{}, params
    )
  end

  defp create_category(socket, params: {params, meta_keywords, main_image, header_image, description, alias_link, sub},
                               uploads: {_uploaded_main_image_files, _uploaded_header_image_files}) do

      {state_main_image, state_header_image} = socket.assigns.images

      main_image = if is_nil(main_image), do: state_main_image, else: main_image
      header_image = if is_nil(header_image), do: state_header_image, else: header_image

    socket = case Category.create(
      Map.merge(params, %{
        "meta_keywords" => meta_keywords,
        "main_image" => main_image,
        "header_image" =>  header_image,
        "description" =>  description,
        "alias_link" => alias_link,
        "sub" => sub
      })) do

      {:error, :add, :category, repo_error} ->
        socket
        |> assign([
          changeset: repo_error,
          images: {main_image, header_image}
        ])

      {:ok, :add, :category, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "مجموعه: #{MishkaHtml.title_sanitize(repo_data.title)} درست شده است."})
        socket
        |> put_flash(:info, "مجموعه با موفقیت ایجاد شد")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive))
    end

    {:noreply, socket}
  end

  defp edit_category(socket, params: {params, meta_keywords, main_image, header_image, description, id, alias_link, sub},
                               uploads: {_uploaded_main_image_files, _uploaded_header_image_files}) do

    merge_map = %{
      "id" => id,
      "meta_keywords" => meta_keywords,
      "main_image" => main_image,
      "header_image" =>  header_image,
      "description" =>  description,
      "alias_link" => alias_link,
      "sub" => sub
    }
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})

    merged = Map.merge(params, merge_map)
    {main_image, header_image} = socket.assigns.images

    main_image_exist_file = if(Map.has_key?(merged, "main_image"), do: %{}, else: %{"main_image" => main_image})
    header_image_exist_file = if(Map.has_key?(merged, "header_image"), do: %{}, else: %{"header_image" => header_image})

    exist_images = Map.merge(main_image_exist_file, header_image_exist_file)

    socket = case Category.edit(Map.merge(merged, exist_images)) do
      {:error, :edit, :category, repo_error} ->
        socket
        |> assign([
          changeset: repo_error,
          images: {main_image, header_image}
        ])

      {:ok, :edit, :category, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "مجموعه: #{MishkaHtml.title_sanitize(repo_data.title)} به روز شده است."})
        socket
        |> put_flash(:info, "مجموعه به روز رسانی شد")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive))

      {:error, :edit, :uuid, _error_tag} ->
        socket
        |> put_flash(:warning, "چنین مجموعه ای وجود ندارد یا ممکن است از قبل حذف شده باشد.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive))
    end

    {:noreply, socket}
  end

  defp creata_category_state(repo_data) do
    Map.drop(repo_data, [:inserted_at, :updated_at, :__meta__, :__struct__, :blog_posts, :id])
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

  def basic_menu_list() do
    [
      %{type: "title", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-4",
      title: "تیتر",
      description: "ساخت تیتر مناسب برای مجموعه مورد نظر"},

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
      class: "col-sm-1",
      title: "وضعیت",
      description: "انتخاب نوع وضعیت می توانید بر اساس دسترسی های کاربران باشد یا نمایش یا عدم نمایش مجموعه به کاربران."},

      %{type: "alias_link", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "convert_title_to_link",
      class: "col-sm-3",
      title: "لینک مجموعه",
      description: "انتخاب لینک مجموعه برای ثبت و نمایش به کاربر. این فیلد یکتا می باشد."},

      %{type: "meta_keywords", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "add_tag",
      class: "col-sm-4",
      title: "کلمات کلیدی",
      description: "انتخاب چندین کلمه کلیدی برای ثبت بهتر مجموعه در موتور های جستجو."},


      %{type: "description", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "editor",
      class: "col-sm-12",
      title: "توضیحات",
      description: "توضیحات اصلی مربوط به مجموعه. این فیلد شامل یک ادیتور نیز می باشد."},


      %{type: "short_description", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "textarea",
      class: "col-sm-6",
      title: "توضیحات کوتاه",
      description: "ساخت بلاک توضیحات کوتاه برای مجموعه"},

      %{type: "main_image", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "upload",
      class: "col-sm-6",
      title: "تصویر اصلی",
      description: "تصویر نمایه مجموعه. این فیلد به صورت تک تصویر می باشد."},


      %{type: "meta_description", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "textarea",
      class: "col-sm-6",
      title: "توضیحات متا",
      description: "توضیحات خلاصه در مورد محتوا که حدود 200 کاراکتر می باشد."},
    ]
  end

  def more_options_menu_list() do
    [

      %{type: "header_image", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "upload",
      class: "col-sm-6",
      title: "تصویر هدر",
      description: "این تصویر در برخی از قالب ها بالای هدر مجموعه نمایش داده می شود"},


      %{type: "sub", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"}
      ],
      form: "text_search",
      class: "col-sm-3",
      title: "زیر مجموعه",
      description: "شما می توانید به واسطه این فیلد مجموعه جدید را زیر مجموعه دیگری بکنید"},

      %{type: "custom_title", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"},
      ],
      form: "text",
      class: "col-sm-3",
      title: "تیتر سفارشی",
      description: "برای نمایش بهتر در برخی از قالب ها استفاده می گردد"},

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
      description: " انتخاب دسترسی رباط ها برای ثبت محتوای مجموعه. لطفا در صورت نداشتن اطلاعات این فیلد را پر نکنید"},

      %{type: "category_visibility", status: [
        %{title: "غیر ضروری", class: "badge bg-info"}
      ],
      options: [
        {"نمایش", :show},
        {"مخفی", :invisibel},
        {"نمایش تست", :test_show},
        {"مخفی تست", :test_invisibel},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش مجموعه",
      description: "نحوه نمایش مجموعه برای مدیریت بهتر دسترسی های کاربران."},

      %{type: "allow_commenting", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اجازه ارسال نظر",
      description: "اجازه ارسال نظر از طرف کاربر در پست های تخصیص یافته به این مجموعه"},


      %{type: "allow_liking", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اجازه پسند کردن",
      description: "امکان یا اجازه پسند کردن پست های مربوط به این مجموعه"},

      %{type: "allow_printing", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اجازه پرینت گرفتن",
      description: "اجازه پرینت گرفتن در صفحه اختصاصی مربوط به پرینت در محتوا"},

      %{type: "allow_reporting", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "گزارش",
      description: "اجازه گزارش دادن کاربران در محتوا های تخصیص یافته در این مجموعه."},

      %{type: "allow_social_sharing", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "شبکه های اجتماعی",
      description: "اجازه فعال سازی دکمه اشتراک گذاری در شبکه های اجتماعی"},

      %{type: "allow_subscription", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اشتراک",
      description: "اجازه مشترک شدن کاربران در محتوا های تخصیص یافته به این مجموعه"},

      %{type: "allow_bookmarking", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "بوکمارک",
      description: "اجازه بوک مارک کردن محتوا به وسیله کاربران."},

      %{type: "allow_notif", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "ناتیفکیشن",
      description: "اجازه ارسال ناتیفیکیشن به کاربران"},

      %{type: "show_hits", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش تعداد بازدید",
      description: "اجازه نمایش تعداد بازدید پست های مربوط به این مجموعه."},

      %{type: "show_time", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "تاریخ ارسال مطلب",
      description: "نمایش یا عدم نمایش تاریخ ارسال در پست های تخصیص یافته در این مجموعه"},

      %{type: "show_authors", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش نویسندگان",
      description: "اجازه نمایش نویسندگان در محتوا های تخصیص یافته به این مجموعه."},

      %{type: "show_category", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "مجموعه",
      description: "اجازه نمایش مجموعه در محتوا های تخصیص یافته به این مجموعه"},

      %{type: "show_links", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "لینک ها",
      description: "اجازه نمایش یا عدم نمایش لینک های پیوستی محتوا های تخصیص یافته  به این مجموعه"},

      %{type: "show_location", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      options: [
        {"بله", true},
        {"خیر", false},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش نقشه",
      description: "اجازه نمایش نقشه در هر محتوا مربوط به این مجموعه."},
    ]
  end

end
