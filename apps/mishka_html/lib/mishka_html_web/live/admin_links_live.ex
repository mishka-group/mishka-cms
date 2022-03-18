defmodule MishkaHtmlWeb.AdminLinksLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaContent.Blog.BlogLink
  alias MishkaContent.Blog.Post

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.BlogLink,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@post_links}
        url={MishkaHtmlWeb.AdminLinksLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(%{"id" => post_id}, session, socket) do
    socket = case Post.show_by_id(post_id) do
      {:ok, :get_record_by_id, _error_tag, record} ->
        if connected?(socket), do: BlogLink.subscribe()
        Process.send_after(self(), :menu, 100)
        assign(socket,
          page_size: 20,
          filters: %{},
          page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت لینک ها مطلب %{title}", title: record.title),
          body_color: "#a29ac3cf",
          user_id: Map.get(session, "user_id"),
          post_links: BlogLink.links(filters: %{section_id: post_id}),
          post_id: post_id,
          link_id: nil
        )

      _ ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین مطلبی وجود ندارد یا از قبل حذف شده است."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case BlogLink.delete(id) do
      {:ok, :delete, :blog_link, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_start_child(%{
          type: "section",
          section: "blog_link",
          section_id: repo_data.id,
          action: "delete",
          priority: "medium",
          status: "info"
        }, %{user_action: "live_delete_link", post_id: socket.assigns.post_id, type: "admin", user_id: socket.assigns.user_id})

        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "لینک: %{title} حذف شده است.", title: MishkaHtml.title_sanitize(repo_data.title))})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "لینک با موفقیت حذف شد"))

      {:error, :delete, type, :blog_link} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین لینکی وجود ندارد یا ممکن است از قبل حذف شده باشد."))

      {:error, :delete, :blog_link, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف لینک اتفاق افتاده است."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:blog_link, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        assign(socket,
          post_links: BlogLink.links(filters: %{section_id: socket.assigns.post_id})
        )

      :deleted ->
        assign(socket,
          post_links: BlogLink.links(filters: %{section_id: socket.assigns.post_id})
        )
       _ ->  socket
    end

    {:noreply, socket}
  end


  selected_menue("MishkaHtmlWeb.AdminPostLinksLive")

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def section_fields() do
    [
      ListItemComponent.text_field("title", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر"),
      {true, false, false}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.select_field("status", [1, 4], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "وضعیت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), "active"},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "soft_delete"},
      ],
      {true, false, false}),
      ListItemComponent.select_field("type", [1, 4], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "نوع لینک"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "پایین"), "bottom"},
        {MishkaTranslator.Gettext.dgettext("html_live", "وسط"), "inside"},
        {MishkaTranslator.Gettext.dgettext("html_live", "ویژه"), "featured"}
      ],
      {true, false, false}),
      ListItemComponent.select_field("robots", [3, 5, 6], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "رباط"),
      [
        {"IndexFollow", "IndexFollow"},
        {"IndexNoFollow", "IndexNoFollow"},
        {"NoIndexFollow", "NoIndexFollow"},
        {"NoIndexNoFollow", "NoIndexNoFollow"}
      ],
      {true, false, false}),
      ListItemComponent.time_field("inserted_at", [1], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "ثبت"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "اضافه کردن لینک"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminLinkLive, assigns.post_id),
            class: "btn btn-outline-danger"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برگشت به مطالب"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive),
            class: "btn btn-outline-primary"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف لینک از این مطلب"),
            class: "btn btn-outline-danger vazir"
          },
          %{
            method: :redirect_keys,
            router: MishkaHtmlWeb.AdminLinkLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "ویرایش"),
            class: "btn btn-outline-info vazir",
            keys: [
              {:without_key, assigns.post_id},
              {:id, :id}
            ]
          }
        ]
      },
      title: assigns.page_title,
      activities_info: %{
        title: assigns.page_title,
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "لینک"),
        action: :section,
        action_by: :section,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید برای هر مطلب یک سری لینک با توضیحات اضافه کنید که به عنوان پیوست یا نمایش می تواند در تولید محتوا کاربردی باشد.") %>
        <div class="space30"></div>
      """
    }
  end
end
