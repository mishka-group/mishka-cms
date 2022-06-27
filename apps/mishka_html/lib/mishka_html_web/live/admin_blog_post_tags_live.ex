defmodule MishkaHtmlWeb.AdminBlogPostTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag
  alias MishkaContent.Blog.TagMapper
  alias MishkaContent.Blog.Post

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.Blog.TagMapper,
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
        list={@tags}
        url={MishkaHtmlWeb.AdminBlogPostTagsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(%{"id" => post_id}, session, socket) do
    if connected?(socket) do
      Tag.subscribe()
      TagMapper.subscribe()
    end

    socket =
      case Post.show_by_id(post_id) do
        {:error, :get_record_by_id, _error_atom} ->
          socket
          |> put_flash(
            :warning,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "چنین مطلبی وجود ندارد یا ممکن است از قبل حذف شده باشد."
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))

        {:ok, :get_record_by_id, _error_atom, repo_data} ->
          Process.send_after(self(), :menu, 100)

          socket
          |> assign(
            page_size: 20,
            filters: %{},
            post_id: post_id,
            page_title: "#{repo_data.title}",
            body_color: "#a29ac3cf",
            user_id: Map.get(session, "user_id"),
            id: nil,
            tags: Tag.post_tags(post_id),
            search: []
          )
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => tag_id} = _params, socket) do
    TagMapper.delete(socket.assigns.post_id, tag_id)

    MishkaContent.General.Activity.create_activity_by_start_child(
      %{
        type: "section",
        section: "blog_tag",
        section_id: tag_id,
        action: "delete",
        priority: "low",
        status: "info"
      },
      %{
        user_action: "live_delete_post_tag",
        post_id: socket.assigns.post_id,
        type: "admin",
        user_id: socket.assigns.user_id
      }
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_tag", %{"_target" => _target, "search-tag-title" => tag_title}, socket) do
    search_tags = Tag.tags(conditions: {1, 5}, filters: %{title: tag_title}).entries

    socket =
      socket
      |> assign(search: search_tags)

    {:noreply, socket}
  end

  def handle_event("search_tag", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("add_tag", %{"id" => tag_id}, socket) do
    socket =
      case TagMapper.create(%{post_id: socket.assigns.post_id, tag_id: tag_id}) do
        {:error, :add, _error_tag, _repo_error} ->
          socket

        {:ok, :add, _error_tag, repo_data} ->
          MishkaContent.General.Activity.create_activity_by_start_child(
            %{
              type: "section",
              section: "blog_tag",
              section_id: repo_data.id,
              action: "add",
              priority: "low",
              status: "info"
            },
            %{
              user_action: "live_add_post_tag",
              post_id: socket.assigns.post_id,
              type: "admin",
              user_id: socket.assigns.user_id
            }
          )

          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({tag, :ok, repo_record}, socket) when tag in [:blog_tag_mapper, :tag] do
    socket =
      case repo_record.__meta__.state do
        :loaded ->
          Notif.notify_subscribers(%{
            id: repo_record.id,
            msg:
              MishkaTranslator.Gettext.dgettext("html_live", "یک برچسب به مطلب %{title} اضافه شد",
                title: socket.assigns.page_title
              )
          })

          socket
          |> assign(tags: Tag.post_tags(socket.assigns.post_id))

        :deleted ->
          Notif.notify_subscribers(%{
            id: repo_record.id,
            msg:
              MishkaTranslator.Gettext.dgettext("html_live", "یک برچسب از مطلب %{title} حذف شد.",
                title: socket.assigns.page_title
              )
          })

          socket
          |> assign(tags: Tag.post_tags(socket.assigns.post_id))

        _ ->
          socket
      end

    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogPostTagsLive")

  def handle_info(_params, socket) do
    {:noreply, socket}
  end

  def section_fields() do
    [
      ListItemComponent.text_field(
        "title",
        [1],
        "col header1",
        MishkaTranslator.Gettext.dgettext("html_live", "تیتر"),
        {true, true, false},
        &MishkaHtml.title_sanitize/1
      ),
      ListItemComponent.text_field(
        "custom_title",
        [1],
        "col header2",
        MishkaTranslator.Gettext.dgettext("html_live", "تیتر سفارشی"),
        {true, true, false},
        &MishkaHtml.title_sanitize/1
      ),
      ListItemComponent.select_field(
        "robots",
        [3, 5, 6],
        "col header3",
        MishkaTranslator.Gettext.dgettext("html_live", "رباط"),
        [
          {"IndexFollow", "IndexFollow"},
          {"IndexNoFollow", "IndexNoFollow"},
          {"NoIndexFollow", "NoIndexFollow"},
          {"NoIndexNoFollow", "NoIndexNoFollow"}
        ],
        {true, true, false}
      ),
      ListItemComponent.time_field(
        "inserted_at",
        [1],
        "col header4",
        MishkaTranslator.Gettext.dgettext("html_live", "ثبت"),
        false,
        {true, false, false}
      )
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
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برچسب ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagsLive),
            class: "btn btn-outline-info"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live", "حذف برچسب از این مطلب"),
            class: "btn btn-outline-danger vazir"
          }
        ]
      },
      title:
        MishkaTranslator.Gettext.dgettext("html_live_templates", "برچسب موضوع %{title}",
          title: assigns.page_title
        ),
      activities_info: %{
        title:
          MishkaTranslator.Gettext.dgettext("html_live_templates", "برچسب موضوع %{title}",
            title: assigns.page_title
          ),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "برچسب"),
        action: :section,
        action_by: :section
      },
      custom_operations: nil,
      description: ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید به مطلب مورد نظر یک یا چند برچسب تخصیص بدهید یا از لیست برچسب های مطلب مذکور موردی که نیاز ندارید را حذف کنید.") %>
        <div class="space30"></div>
        <div class="col-sm-12">
          <div class="clearfix"></div>
          <div class="space40"></div>
          <hr>
          <div class="space40"></div>
          <form phx-change="search_tag" id="tag-form">
              <div class="col-md-4 vazir">
                  <label for="blogPostTags" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "جستجو برچسب و اضافه کردن به مطلب") %></label>
                  <div class="space10"> </div>
                  <input type="text" class="title-input-text form-control" name="search-tag-title" id="search-tag">
                  <div class="col space10"> </div>
                  <div class="space10"></div>
                  <div class="col" id="search_tags">
                      <%= for {item, color} <- Enum.zip(@search, Stream.cycle(["warning", "info" , "danger" , "success" , "primary" ])) do %>
                          <div class={"list-group-item list-group-item-#{color}"} aria-current="true">
                              <div class="d-flex w-100 justify-content-between">
                                  <h4 class="mb-1">
                                      <%= item.title %>
                                  </h4>

                                  <small class="text-muted">
                                      <div class="btn btn-outline-primary vazir" phx-click="add_tag" phx-value-id={item.id}>
                                          <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "اضافه کردن") %>
                                      </div>
                                  </small>
                              </div>
                          </div>
                      <% end %>
                  </div>
              </div>
          </form>
        </div>
      """
    }
  end
end
