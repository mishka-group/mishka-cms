defmodule MishkaHtmlWeb.AdminCommentLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaContent.Cache.ContentDraftManagement
  alias MishkaContent.General.Comment
  @error_atom :comment

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.General.Comment,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminCommentView, "admin_comment_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)

    socket =
      assign(socket,
        dynamic_form: [],
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت ویرایش نظر"),
        body_color: "#a29ac3cf",
        basic_menu: false,
        id: nil,
        user_id: Map.get(session, "user_id"),
        drafts: ContentDraftManagement.drafts_by_section(section: "comment"),
        draft_id: nil,
        user_search: [],
        changeset: comment_changeset()
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    all_field = create_menu_list(basic_menu_list(), [])

    socket =
      case Comment.show_by_id(id) do
        {:error, :get_record_by_id, @error_atom} ->
          socket
          |> put_flash(
            :warning,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد."
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

        {:ok, :get_record_by_id, @error_atom, repo_data} ->
          comment =
            Enum.map(all_field, fn field ->
              record =
                Enum.find(creata_comment_state(repo_data), fn cat -> cat.type == field.type end)

              Map.merge(field, %{value: if(is_nil(record), do: nil, else: record.value)})
            end)
            |> Enum.reject(fn x -> x.value == nil end)

          description = Enum.find(comment, fn cm -> cm.type == "description" end)

          socket
          |> assign(
            dynamic_form: comment,
            id: repo_data.id
          )
          |> push_event("update-editor-html", %{html: description.value})
      end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> put_flash(
      :warning,
      MishkaTranslator.Gettext.dgettext(
        "html_live",
        "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد."
      )
    )
    |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

    {:noreply, socket}
  end

  # Live CRUD
  basic_menu()

  make_all_basic_menu()

  delete_form()

  clear_all_field(comment_changeset())

  editor_draft("comment", false, [], when_not: [])

  @impl true
  def handle_event("save", %{"comment" => params}, socket) do
    socket =
      case MishkaHtml.html_form_required_fields(basic_menu_list(), params) do
        [] ->
          socket

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

    case Comment.edit(Map.merge(params, %{"id" => socket.assigns.id})) do
      {:error, :edit, @error_atom, repo_error} ->
        socket =
          socket
          |> assign(changeset: repo_error)

        {:noreply, socket}

      {:ok, :edit, @error_atom, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_start_child(
          %{
            type: "section",
            section: "comment",
            section_id: repo_data.id,
            action: "edit",
            priority: "medium",
            status: "info"
          },
          %{
            user_action: "live_comment_edit",
            post_id: repo_data.post_id,
            type: "admin",
            user_id: socket.assigns.user_id
          }
        )

        if(!is_nil(Map.get(socket.assigns, :draft_id)),
          do:
            MishkaContent.Cache.ContentDraftManagement.delete_record(id: socket.assigns.draft_id)
        )

        socket =
          socket
          |> put_flash(
            :info,
            MishkaTranslator.Gettext.dgettext("html_live", "نظر به روز رسانی شد")
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

        {:noreply, socket}

      {:error, :edit, :uuid, _error_tag} ->
        socket =
          socket
          |> put_flash(
            :warning,
            MishkaTranslator.Gettext.dgettext(
              "html_live",
              "چنین نظری وجود ندارد یا ممکن است از قبل حذف شده باشد."
            )
          )
          |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))

        {:noreply, socket}
    end
  end

  def handle_event("save", _params, socket) do
    socket =
      case MishkaHtml.html_form_required_fields(basic_menu_list(), []) do
        [] ->
          socket

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

  selected_menue("MishkaHtmlWeb.AdminCommentLive")

  defp creata_comment_state(repo_data) do
    Map.drop(repo_data, [
      :inserted_at,
      :updated_at,
      :__meta__,
      :__struct__,
      :users,
      :id,
      :comments_likes
    ])
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

  defp comment_changeset(params \\ %{}) do
    MishkaDatabase.Schema.MishkaContent.Comment.changeset(
      %MishkaDatabase.Schema.MishkaContent.Comment{},
      params
    )
  end

  def search_fields(type) do
    Enum.find(basic_menu_list(), fn x -> x.type == type end)
  end

  def basic_menu_list() do
    [
      %{
        type: "status",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        options: [
          {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), :inactive},
          {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), :active},
          {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), :archived},
          {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), :soft_delete}
        ],
        form: "select",
        class: "col-sm-4",
        title: MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
        description:
          MishkaTranslator.Gettext.dgettext("html_live", "وضعیت نظر ارسالی از طرف کاربر")
      },
      %{
        type: "priority",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        options: [
          {MishkaTranslator.Gettext.dgettext("html_live", "بدون اولویت"), :none},
          {MishkaTranslator.Gettext.dgettext("html_live", "پایین"), :low},
          {MishkaTranslator.Gettext.dgettext("html_live", "متوسط"), :medium},
          {MishkaTranslator.Gettext.dgettext("html_live", "بالا"), :high},
          {MishkaTranslator.Gettext.dgettext("html_live", "ویژه"), :featured}
        ],
        form: "select",
        class: "col-sm-4",
        title: MishkaTranslator.Gettext.dgettext("html_live", "اولویت"),
        description: MishkaTranslator.Gettext.dgettext("html_live", "اولیت نظر ارسالی")
      },
      %{
        type: "section",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        options: [
          {MishkaTranslator.Gettext.dgettext("html_live", "مطالب"), :blog_post}
        ],
        form: "select",
        class: "col-sm-4",
        title: MishkaTranslator.Gettext.dgettext("html_live", "بخش"),
        description: MishkaTranslator.Gettext.dgettext("html_live", "بخش تخصیص یافته به نظر")
      },
      %{
        type: "section_id",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        form: "text",
        class: "col-sm-3",
        title: MishkaTranslator.Gettext.dgettext("html_live", "شناسه بخش"),
        description:
          MishkaTranslator.Gettext.dgettext("html_live", "شناسه بخش تخصیص یافته به نظر ارسالی")
      },
      %{
        type: "sub",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        form: "text",
        class: "col-sm-3",
        title: MishkaTranslator.Gettext.dgettext("html_live", "شناسه نظر"),
        description:
          MishkaTranslator.Gettext.dgettext("html_live", "شناسه بخش تخصیص یافته به نظر ارسالی")
      },
      %{
        type: "user_id",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        form: "text",
        class: "col-sm-3",
        title: MishkaTranslator.Gettext.dgettext("html_live", "شناسه کاربر"),
        description:
          MishkaTranslator.Gettext.dgettext(
            "html_live",
            "هر نظر باید به یک کاربر تخصیص پیدا کند."
          )
      },
      %{
        type: "description",
        status: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live", "ضروری"),
            class: "badge bg-danger"
          }
        ],
        form: "textarea",
        class: "col-sm-12",
        title: MishkaTranslator.Gettext.dgettext("html_live", "توضیحات"),
        description: MishkaTranslator.Gettext.dgettext("html_live", "نظر ارسالی از طرف کاربر")
      }
    ]
  end
end
