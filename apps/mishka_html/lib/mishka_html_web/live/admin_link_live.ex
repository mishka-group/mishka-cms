defmodule MishkaHtmlWeb.AdminLinkLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaContent.Blog.BlogLink
  alias MishkaContent.Blog.Post

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.BlogLink,
      redirect: __MODULE__,
      router: Routes

  @error_atom :blog_link

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_link_live.html", assigns)
  end

  @impl true
  def mount(%{"post_id" => post_id}, session, socket) do
    socket = case Post.show_by_id(post_id) do
      {:ok, :get_record_by_id, _error_tag, record} ->
        Process.send_after(self(), :menu, 100)
        assign(socket,
          dynamic_form:  create_menu_list(basic_menu_list(), []),
          page_title: MishkaTranslator.Gettext.dgettext("html_live", "ساخت یا ویرایش لینک برای مطلب %{title}", title: MishkaHtml.title_sanitize(record.title)),
          body_color: "#a29ac3cf",
          basic_menu: false,
          editor: nil,
          post_id: post_id,
          id: nil,
          user_id: Map.get(session, "user_id"),
          draft_id: nil,
          changeset: link_changeset()
        )

      _ ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین مطلبی وجود ندارد یا از قبل حذف شده است."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => link_id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket = case BlogLink.show_by_id(link_id) do
      {:error, :get_record_by_id, @error_atom} ->

        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین لینکی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminLinksLive, socket.assigns.post_id))

      {:ok, :get_record_by_id, @error_atom, repo_data} ->

        comment = Enum.map(all_field, fn field ->
          record = Enum.find(creata_link_state(repo_data), fn cat -> cat.type == field.type end)
          Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
        end)
        |> Enum.reject(fn x -> x.value == nil end)

        description = Enum.find(comment, fn cm -> cm.type == "short_description" end)

        socket
        |> assign([
          dynamic_form: comment,
          id: repo_data.id,
          editor: description.value
        ])
        |> push_event("update-editor-html", %{html: description.value})
    end

      {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # Live CRUD
  save_editor()

  make_all_basic_menu()

  delete_form()

  editor_draft("blog_link", false, [], when_not: [])

  @impl true
  def handle_event("save", %{"blog_link" => params}, socket) do
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

    socket = case socket.assigns.id do
      nil -> create_link(socket, params)
      _ -> update_link(socket, params)
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


  selected_menue("MishkaHtmlWeb.AdminLinkLive")


  defp creata_link_state(repo_data) do
    Map.drop(repo_data, [:inserted_at, :updated_at, :__meta__, :__struct__, :id, :section_id, :short_link])
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

  defp link_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.BlogLink.changeset(
      %MishkaDatabase.Schema.MishkaContent.BlogLink{}, params
    )
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end


  defp create_link(socket, params) do
    socket = case BlogLink.create(Map.merge(params, %{"short_description" => socket.assigns.editor, "section_id" => socket.assigns.post_id})) do
      {:error, :add, :blog_link, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :add, :blog_link, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "لینک: %{title} درست شده است.", title: repo_data.title)})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "لینک مورد نظر ساخته شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminLinksLive, socket.assigns.post_id))
    end
    socket
  end

  defp update_link(socket, params) do
    socket = case BlogLink.edit(Map.merge(params, %{"id" => socket.assigns.id, "short_description" => socket.assigns.editor, "section_id" => socket.assigns.post_id})) do
      {:error, :edit, :blog_link, repo_error} ->
        socket
        |> assign([changeset: repo_error])

      {:ok, :edit, :blog_link, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "لینک: %{title} به روز رسانی شده است.", title: repo_data.title)})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "نقش مورد نظر به روز رسانی شد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminLinksLive, socket.assigns.post_id))
    end
    socket
  end

  def basic_menu_list() do
    [
      %{type: "title", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "پیشنهادی", class: "badge bg-dark")}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "تیتر لینک"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "شما می توانید برای هر لینک یک تیتر قرار بدهید که به سئو شما نیز کمک خواهد کرد")},

      %{type: "status", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), :inactive},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), :active},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), :archived},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), :soft_delete},
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "انتخاب نوع وضعیت می توانید بر اساس دسترسی های کاربران باشد یا نمایش یا عدم نمایش لینک به کاربران.")},


      %{type: "type", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      options: [
        {MishkaTranslator.Gettext.dgettext("html_live", "پایین"), :bottom},
        {MishkaTranslator.Gettext.dgettext("html_live", "وسط"), :inside},
        {MishkaTranslator.Gettext.dgettext("html_live", "ویژه"), :featured},
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "نوع فعال سازی"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "این فیلد برای مشخص کردن نحوه نمایش در یک محتوا می باشد که بستگی به طراح قالب دارد که چطور از آن استفاده کند. در قالب پیشفرض اگر پایین انتخاب شود آخر مطلب نمایش داده می شود")},

      %{type: "link", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "پیشنهادی", class: "badge bg-dark")}
      ],
      form: "text",
      class: "col-sm-3",
      title: MishkaTranslator.Gettext.dgettext("html_live", "لینک"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "شما می توانید به واسطه این فیلد لینکی که می خواهید ریدایرکت انجام شود را قرار بدهید. لازم به ذکر است اگر تنظیمات کوتاه کننده لینک فعال باشد و لینک کوتاه نیز قرار گرفته باشد اولیت کلیک کردن با لینک کوتاه می باشد.")},

      %{type: "robots", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر ضروری"), class: "badge bg-info"},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "غیر پیشنهادی", class: "badge bg-warning")},
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "هشدار", class: "badge bg-secondary")},
      ],
      options: [
        {"IndexFollow", :IndexFollow},
        {"IndexNoFollow", :IndexNoFollow},
        {"NoIndexFollow", :NoIndexFollow},
        {"NoIndexNoFollow", :NoIndexNoFollow},
      ],
      form: "select",
      class: "col-sm-2",
      title: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت رباط ها"),
      description: MishkaTranslator.Gettext.dgettext("html_live", " انتخاب دسترسی رباط ها برای ثبت لینک محتوا. لطفا در صورت نداشتن اطلاعات این فیلد را پر نکنید")},

      %{type: "short_description", status: [
        %{title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"), class: "badge bg-danger"}
      ],
      form: "editor",
      class: "col-sm-12",
      title: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات کوتاه"),
      description: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات کوتاه مربوط به لینک. این فیلد شامل یک ادیتور نیز می باشد.")},
    ]
  end
end
