defmodule MishkaHtmlWeb.AdminBlogPostAuthorsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Author
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت نویسندگان")

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.Blog.Author,
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
        list={@authors}
        url={MishkaHtmlWeb.AdminBlogPostAuthorsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(%{"post_id" => post_id}, session, socket) do
    socket = case MishkaContent.Blog.Post.show_by_id(post_id) do
      {:ok, :get_record_by_id, _error_tag, _record} ->
        Process.send_after(self(), :menu, 100)
        assign(socket,
          page_size: 20,
          filters: %{},
          page_title: @section_title,
          body_color: "#a29ac3cf",
          user_id: Map.get(session, "user_id"),
          authors: Author.authors(post_id),
          search_author: [],
          post_id: post_id
        )

      _ ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین مطلبی وجود ندارد یا از قبل حذف شده است."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("add_author", %{"user-id" => user_id}, socket) do
    socket = case Author.create(%{post_id: socket.assigns.post_id, user_id: user_id}) do
      {:ok, :add, :blog_author, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "blog_author",
          section_id: repo_data.id,
          action: "add",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{user_action: "live_add_author", type: "admin"})

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "نویسنده با موفقت ثبت شد."))

      _ ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "کاربر تکراری امکان ثبت ندارد. یا ممکن است در موقع ثبت کاربر مذکور حذف شده باشد."))
    end
    |> push_redirect(to: Routes.live_path(socket, __MODULE__, socket.assigns.post_id))

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket = case Author.delete(id) do
      {:ok, :delete, :blog_author, repo_data} ->

        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "blog_author",
          section_id: repo_data.id,
          action: "delete",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{user_action: "live_delete_author", type: "admin"})

        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "نویسنده با موفقت حذف شد"))
        |> assign(authors: Author.authors(repo_data.post_id))

      _ ->

        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "خطایی در حذف نویسنده پیش آمده است."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_user", %{"full_name" => full_name, "role" => role}, socket) do

    filters =
      [{:full_name, full_name}, {:role, role}]
      |> Enum.reject(fn {_k, v} -> v == "" end)
      |> Enum.into(%{})

    search_author = MishkaUser.User.users(conditions: {1, 10}, filters: filters)

    socket =
      socket
      |> assign(search_author: search_author)

    {:noreply, socket}
  end


  selected_menue("MishkaHtmlWeb.AdminBlogPostAuthorsLive")

  # skip Task info
  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp author_temporary_image() do
    """
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-cup" viewBox="0 0 16 16">
      <path d="M1 2a1 1 0 0 1 1-1h11a1 1 0 0 1 1 1v1h.5A1.5 1.5 0 0 1 16 4.5v7a1.5 1.5 0 0 1-1.5 1.5h-.55a2.5 2.5 0 0 1-2.45 2h-8A2.5 2.5 0 0 1 1 12.5V2zm13 10h.5a.5.5 0 0 0 .5-.5v-7a.5.5 0 0 0-.5-.5H14v8zM13 2H2v10.5A1.5 1.5 0 0 0 3.5 14h8a1.5 1.5 0 0 0 1.5-1.5V2z"></path>
    </svg>
    """
  end

  def section_fields() do
    [
      ListItemComponent.custom_field("author_image", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "تصویر"), author_temporary_image(),
      {true, false, false}),
      ListItemComponent.link_field("user_full_name", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "نویسنده"),
      {MishkaHtmlWeb.AdminUserLive, :user_id},
      {true, false, false}),
      ListItemComponent.time_field("inserted_at", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "ثبت"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برگشت به مطالب"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive),
            class: "btn btn-outline-danger"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف"),
            class: "btn btn-outline-danger vazir"
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_component", "نویسندگان"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "نویسنده"),
        action: :section,
        action_by: :section,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "در این بخش می توانید به تعداد نویسندگان یک مطلب اضافه یا کم کنید.") %>
        <div class="space30"></div>
        <div class="clearfix"></div>
        <form  phx-change="search_user" id="UserFormSearch">
          <div class="row vazir">
              <div class="col-sm-3" id="UserFullNameSearch">
                  <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "نام کامل") %></label>
                  <div class="space10"> </div>
                  <input type="text" class="title-input-text form-control" id="full_name" name="full_name">
                  <div class="col space10"> </div>
              </div>
              <div class="col-sm-3" id="RoleID">
              <label for="role" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "نقش") %></label>
              <div class="col space10"> </div>
              <select class="form-select" id="role-search" name="role">
                <option value="" selected><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "انتخاب") %></option>
                <%= for role <- MishkaUser.Acl.Role.roles() do %>
                  <option value={role.id}><%= role.display_name %></option>
                <% end %>
              </select>
            </div>
          </div>
        </form>
        <div class="clearfix"></div>
        <div class="col space30"> </div>

        <div class="col">
        <%= for {user, color} <- Enum.zip(@search_author, Stream.cycle(["warning", "info", "danger", "success", "primary"])) do %>
            <a class={"col-sm-6 vazir list-group-item list-group-item-#{color}"} aria-current="true" id={user.id} phx-click="add_author" phx-value-user-id={user.id}>
                <div class="d-flex w-100 justify-content-between">
                    <h4 class="mb-1"><%= MishkaHtml.full_name_sanitize(user.full_name) %></h4>
                    <small>
                    <.live_component module={MishkaHtmlWeb.Public.TimeConverterComponent}
                            id={"inserted-#{user.id}-component"}
                            span_id={"inserted-#{user.id}-component"}
                            time={user.inserted_at}
                    />
                    </small>
                </div>
            </a>
        <% end %>
        </div>
      """
    }
  end
end
