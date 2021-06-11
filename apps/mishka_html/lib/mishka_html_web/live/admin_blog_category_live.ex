defmodule MishkaHtmlWeb.AdminBlogCategoryLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  def mount(_params, _session, socket) do
    changeset =
      MishkaDatabase.Schema.MishkaContent.Blog.Category.changeset(
        %MishkaDatabase.Schema.MishkaContent.Blog.Category{}, %{}
      )

    socket =
      assign(socket,
        dynamic_form: [],
        page_title: "مدیریت ساخت مجموعه",
        basic_menu: false,
        options_menu: false,
        changeset: changeset,
        trigger_submit: false)
        |> assign(:uploaded_files, [])
        |> allow_upload(:main_image, accept: ~w(.jpg .jpeg .png), max_entries: 1, max_file_size: 10_000_000,)
        |> allow_upload(:header_image, accept: ~w(.jpg .jpeg .png), max_entries: 1, max_file_size: 10_000_000,)
    {:ok, socket}
  end

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

  def handle_event("basic_menu", _params, socket) do
    {:noreply, assign(socket, [basic_menu: !socket.assigns.basic_menu, options_menu: false])}
  end

  def handle_event("options_menu", %{"type" => type, "class" => class}, socket) do
    new_socket = case check_type_in_list(socket.assigns.dynamic_form, %{type: type, value: nil, class: class}, type) do
      {:ok, :add_new_item_to_list, _new_item} ->

        assign(socket, [
          basic_menu: false,
          options_menu: false,
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

  def handle_event("options_menu", _params, socket) do
    {:noreply, assign(socket, [basic_menu: false, options_menu: !socket.assigns.options_menu])}
  end

  def handle_event("save", %{"category" => params}, socket) do
    socket = case Category.create(params) do
      {:error, :add, :category, repo_error} ->
        IO.inspect(repo_error)
          assign(socket,
            changeset: repo_error)

      {:ok, :add, :category, repo_data} ->
          assign(socket,
            dynamic_form: [],
            basic_menu: false,
            options_menu: false,
            trigger_submit: false)
    end

    {:noreply, socket}
  end

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

  def handle_event("clear_all_field", _, socket) do
    changeset =
      MishkaDatabase.Schema.MishkaContent.Blog.Category.changeset(
        %MishkaDatabase.Schema.MishkaContent.Blog.Category{}, %{}
      )

    socket =
      socket
      |> assign([
        basic_menu: false,
        changeset: changeset,
        options_menu: false,
        dynamic_form: []
      ])

    {:noreply, socket}
  end

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

  def handle_event("draft", %{"_target" => ["category", type], "category" => params}, socket) when type not in ["main_image", "main_image"] do
    IO.inspect(params)
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
        dynamic_form: new_dynamic_form
      ])

    {:noreply, socket}
  end

  def handle_event("draft", params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref, "upload_field" => field} = params, socket) do
    {:noreply, cancel_upload(socket, String.to_atom(field), ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end



  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"





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

  defp basic_menu_list() do
    [
      %{type: "title", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "text",
      class: "col-sm-6",
      title: "تیتر",
      description: "ساخت تیتر مناسب برای مجموعه مورد نظر"},

      %{type: "short_description", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "textarea",
      class: "col-sm-12",
      title: "توضیحات کوتاه",
      description: "ساخت بلاک توضیحات کوتاه برای مجموعه"},

      %{type: "main_image", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "upload",
      class: "col-sm-6",
      title: "تصویر اصلی",
      description: "تصویر نمایه مجموعه. این فیلد به صورت تک تصویر می باشد."},

      %{type: "description", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "editor",
      class: "col-sm-12",
      title: "توضیحات",
      description: "توضیحات اصلی مربوط به مجموعه. این فیلد شامل یک ادیتور نیز می باشد."},

      %{type: "status", status: [
        %{title: "ضروری", class: "badge bg-danger"}
      ],
      form: "select",
      class: "col-sm-2",
      title: "وضعیت",
      description: "انتخاب نوع وضعیت می توانید بر اساس دسترسی های کاربران باشد یا نمایش یا عدم نمایش مجموعه به کاربران."},

      %{type: "alias_link", status: [
        %{title: "ضروری", class: "badge bg-danger"},
        %{title: "یکتا", class: "badge bg-success"}
      ],
      form: "text",
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

  defp more_options_menu_list() do
    [
      %{type: "sub", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"}
      ],
      form: "text_search",
      class: "col-sm-3",
      title: "زیر مجموعه",
      description: "شما می توانید به واسطه این فیلد مجموعه جدید را زیر مجموعه دیگری بکنید"},

      %{type: "header_image", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "upload",
      class: "col-sm-6",
      title: "تصویر هدر",
      description: "این تصویر در برخی از قالب ها بالای هدر مجموعه نمایش داده می شود"},

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
      form: "select",
      class: "col-sm-2",
      title: "وضعیت رباط ها",
      description: " انتخاب دسترسی رباط ها برای ثبت محتوای مجموعه. لطفا در صورت نداشتن اطلاعات این فیلد را پر نکنید"},

      %{type: "category_visibility", status: [
        %{title: "غیر ضروری", class: "badge bg-info"}
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش مجموعه",
      description: "نحوه نمایش مجموعه برای مدیریت بهتر دسترسی های کاربران."},

      %{type: "allow_commenting", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اجازه ارسال نظر",
      description: "اجازه ارسال نظر از طرف کاربر در پست های تخصیص یافته به این مجموعه"},


      %{type: "allow_liking", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "غیر پیشنهادی", class: "badge bg-warning"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اجازه پسند کردن",
      description: "امکان یا اجازه پسند کردن پست های مربوط به این مجموعه"},

      %{type: "allow_printing", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اجازه پرینت گرفتن",
      description: "اجازه پرینت گرفتن در صفحه اختصاصی مربوط به پرینت در محتوا"},

      %{type: "allow_reporting", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "گزارش",
      description: "اجازه گزارش دادن کاربران در محتوا های تخصیص یافته در این مجموعه."},

      %{type: "allow_social_sharing", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
        %{title: "پیشنهادی", class: "badge bg-dark"}
      ],
      form: "select",
      class: "col-sm-2",
      title: "شبکه های اجتماعی",
      description: "اجازه فعال سازی دکمه اشتراک گذاری در شبکه های اجتماعی"},

      %{type: "allow_subscription", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "اشتراک",
      description: "اجازه مشترک شدن کاربران در محتوا های تخصیص یافته به این مجموعه"},

      %{type: "allow_bookmarking", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "بوکمارک",
      description: "اجازه بوک مارک کردن محتوا به وسیله کاربران."},

      %{type: "allow_notif", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "ناتیفکیشن",
      description: "اجازه ارسال ناتیفیکیشن به کاربران"},

      %{type: "show_hits", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش تعداد بازدید",
      description: "اجازه نمایش تعداد بازدید پست های مربوط به این مجموعه."},

      %{type: "show_time", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش تاریخ ارسال مطلب",
      description: "نمایش یا عدم نمایش تاریخ ارسال در پست های تخصیص یافته در این مجموعه"},

      %{type: "show_authors", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش نویسندگان",
      description: "اجازه نمایش نویسندگان در محتوا های تخصیص یافته به این مجموعه."},

      %{type: "show_category", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش مجموعه",
      description: "اجازه نمایش مجموعه در محتوا های تخصیص یافته به این مجموعه"},

      %{type: "show_links", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش لینک ها",
      description: "اجازه نمایش یا عدم نمایش لینک های پیوستی محتوا های تخصیص یافته  به این مجموعه"},

      %{type: "show_location", status: [
        %{title: "غیر ضروری", class: "badge bg-info"},
      ],
      form: "select",
      class: "col-sm-2",
      title: "نمایش نقشه",
      description: "اجازه نمایش نقشه در هر محتوا مربوط به این مجموعه."},
    ]
  end
end
