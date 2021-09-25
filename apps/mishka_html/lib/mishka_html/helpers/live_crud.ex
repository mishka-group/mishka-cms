defmodule MishkaHtml.Helpers.LiveCRUD do
  import Phoenix.LiveView

  defmacro __using__(opts) do
    quote(bind_quoted: [opts: opts]) do
      import MishkaHtml.Helpers.LiveCRUD
      require MishkaHtml.Helpers.LiveCRUD
      @interface_module opts
    end
  end

  defmacro paginate(field_assigned, user_id: user_id)  do
    quote do
      @impl Phoenix.LiveView
      def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        skip_list = Keyword.get(@interface_module, :skip_list)
        {:noreply, MishkaHtml.Helpers.LiveCRUD.paginate_assign(socket, module_selected, unquote(field_assigned), unquote(user_id), skip_list, params: params["params"], page_size: count, page_number: page)}
      end

      @impl Phoenix.LiveView
      def handle_params(%{"page" => page}, _url, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        skip_list = Keyword.get(@interface_module, :skip_list)
        {:noreply, MishkaHtml.Helpers.LiveCRUD.paginate_assign(socket, module_selected, unquote(field_assigned), unquote(user_id), skip_list, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)}
      end

      @impl Phoenix.LiveView
      def handle_params(%{"count" => count} = params, _url, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        skip_list = Keyword.get(@interface_module, :skip_list)
        {:noreply, MishkaHtml.Helpers.LiveCRUD.paginate_assign(socket, module_selected, unquote(field_assigned), unquote(user_id), skip_list, params: params["params"], page_size: count, page_number: 1)}
      end

      @impl Phoenix.LiveView
      def handle_params(_params, _url, socket) do
        {:noreply, socket}
      end
    end
  end

  defmacro list_search_and_action()  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("search", params, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        redirect = Keyword.get(@interface_module, :redirect)
        router = Keyword.get(@interface_module, :router)
        skip_list = Keyword.get(@interface_module, :skip_list)
        count = if(is_nil(params["count"]), do: socket.assigns.page_size, else: params["count"])
        {:noreply, push_patch(socket, to: router.live_path(socket, redirect, params: paginate_assign_filter(params, module_selected, skip_list), count: count))}
      end

      @impl Phoenix.LiveView
      def handle_event("reset", _params, socket) do
        redirect = Keyword.get(@interface_module, :redirect)
        router = Keyword.get(@interface_module, :router)
        {:noreply, push_redirect(socket, to: router.live_path(socket, redirect))}
      end

      @impl Phoenix.LiveView
      def handle_event("open_modal", _params, socket) do
        {:noreply, assign(socket, [open_modal: true])}
      end

      @impl Phoenix.LiveView
      def handle_event("close_modal", _params, socket) do
        {:noreply, assign(socket, [open_modal: false, component: nil])}
      end
    end
  end

  # TODO: we delete Notif to improve it on new version of the project
  defmacro delete_list_item(function, component, user_id, do: after_condition, before: before_condition)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("delete", %{"id" => id} = _params, socket) do
        before_condition = unquote(before_condition)
        before_condition.(id)
        module_selected = Keyword.get(@interface_module, :module)
        skip_list = Keyword.get(@interface_module, :skip_list)
        socket = MishkaHtml.Helpers.LiveCRUD.delete_item_of_list(socket, module_selected, unquote(function), id, unquote(user_id), unquote(component), skip_list, unquote(after_condition))
        {:noreply, socket}
      end
    end
  end

  defmacro delete_list_item(function, component, user_id)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("delete", %{"id" => id} = _params, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        skip_list = Keyword.get(@interface_module, :skip_list)
        socket = MishkaHtml.Helpers.LiveCRUD.delete_item_of_list(socket, module_selected, unquote(function), id, unquote(user_id), unquote(component), skip_list, fn x -> x end)
        {:noreply, socket}
      end
    end
  end

  defmacro soft_delete_list_item(function, record_id, do: after_condition)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("delete", %{"id" => id}, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        {:noreply, soft_delete_item_of_list(socket, id, module_selected, unquote(after_condition), unquote(function), unquote(record_id))}
      end
    end
  end

  defmacro soft_delete_list_item(function, record_id)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("delete", %{"id" => id}, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        {:noreply, soft_delete_item_of_list(socket, id, module_selected, fn -> nil end, unquote(function), unquote(record_id))}
      end
    end
  end

  defmacro update_list(function, user_id)  do
    quote do
      @impl Phoenix.LiveView
      def handle_info({_section, :ok, repo_record}, socket) do
        module_selected = Keyword.get(@interface_module, :module)
        skip_list = Keyword.get(@interface_module, :skip_list)
        socket = case repo_record.__meta__.state do
          :loaded ->
            paginate_assign(socket, module_selected, unquote(function), unquote(user_id), skip_list, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: socket.assigns.page)

          :deleted ->
            paginate_assign(socket, module_selected, unquote(function), unquote(user_id), skip_list, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: socket.assigns.page)

          _ ->  socket
        end

        {:noreply, socket}
      end

      @impl Phoenix.LiveView
      def handle_info(_, socket) do
        {:noreply, socket}
      end
    end
  end

  defmacro selected_menue(module)  do
    quote do
      @impl Phoenix.LiveView
      def handle_info(:menu, socket) do
        MishkaHtmlWeb.Admin.Public.AdminMenu.notify_subscribers({:menu, unquote(module)})
        {:noreply, socket}
      end
    end
  end

  defmacro basic_menu()  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("basic_menu", %{"type" => type, "class" => class}, socket) do
        new_socket = case check_type_list(socket.assigns.dynamic_form, %{type: type, value: nil, class: class}, type) do
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

    end
  end

  defmacro options_menu()  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("options_menu", %{"type" => type, "class" => class}, socket) do
        new_socket = case check_type_list(socket.assigns.dynamic_form, %{type: type, value: nil, class: class}, type) do
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
    end
  end

  defmacro save_editor(section)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("save-editor", %{"html" => params}, socket) do
        draft_id = Ecto.UUID.generate
        socket = case socket.assigns.draft_id do
          nil ->
            MishkaContent.Cache.ContentDraftManagement.save_by_id(draft_id, socket.assigns.user_id, unquote(section), :public, [])
            MishkaContent.Cache.ContentDraftManagement.update_state(id: draft_id, elements: %{editor: params, dynamic_form: [
              %{class: "col-sm-1", type: "status", value: nil},
              %{class: "col-sm-12", type: "description", value: params}
            ]})

            socket
            |> assign([editor: params, draft_id: draft_id])

          record ->
            MishkaContent.Cache.ContentDraftManagement.update_state(id: record, elements: %{editor: params})
            socket
            |> assign([editor: params])
        end

        {:noreply, socket}
      end
    end
  end

  defmacro editor_draft(key, options_menu, extra_params, when_not: list_of_key)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("draft", %{"_target" => ["#{unquote(key)}", type], "#{unquote(key)}" => params}, socket) when type not in unquote(list_of_key) do
        draft(socket, type, params, unquote(options_menu), unquote(extra_params), unquote(key))
      end

      def handle_event("draft", params, socket) do
        {:noreply, socket}
      end

      def handle_event("delete_draft", %{"draft-id" => draft_id}, socket) do
        delete_draft(socket, draft_id)
      end

      def handle_event("select_draft", %{"draft-id" => draft_id}, socket) do
        select_draft(socket, draft_id)
      end
    end
  end


  defmacro delete_form()  do
    quote do
      @impl Phoenix.LiveView
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
    end
  end

  defmacro clear_all_field(changeset)  do
    quote do
      @impl Phoenix.LiveView
      def handle_event("clear_all_field", _, socket) do
        {:noreply, assign(socket, [basic_menu: false, changeset: unquote(changeset), options_menu: false, draft_id: nil, dynamic_form: []])}
      end
    end
  end

  defmacro make_all_basic_menu()  do
    quote do
      @impl Phoenix.LiveView
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
    end
  end

  defmacro make_all_menu()  do
    quote do
      @impl Phoenix.LiveView
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
    end
  end


  def delete_draft(socket, draft_id) do
    MishkaContent.Cache.ContentDraftManagement.delete_record(id: draft_id)
    drafts = Enum.reject(socket.assigns.drafts, fn x -> x.id == draft_id end)

    draft_id = if(draft_id == socket.assigns.draft_id, do: nil, else: socket.assigns.draft_id)

    socket =
      socket
      |> assign(drafts: drafts, draft_id: draft_id)

    {:noreply, socket}
  end

  def select_draft(socket, draft_id) do
    socket = case MishkaContent.Cache.ContentDraftManagement.get_draft_by_id(id: draft_id) do
      {:error, :get_draft_by_id, :not_found} -> socket

      record ->
        socket
        |> assign(dynamic_form: record.dynamic_form, draft_id: record.id, editor: Map.get(record, :editor) || "")
        |> push_event("update-editor-html", %{html: Map.get(record, :editor) || ""})
    end

    {:noreply, socket}
  end

  def draft(socket, type, params, options_menu, extra_params, key) do
    {_key, value} = Map.take(params, [type])
    |> Map.to_list()
    |> List.first()

    alias_link = if(type == "title", do: MishkaHtml.create_alias_link(params["title"]), else: Map.get(socket.assigns, :alias_link))

    new_dynamic_form = Enum.map(socket.assigns.dynamic_form, fn x -> if x.type == type, do: Map.merge(x, %{value: value}), else: x end)
    dynamic_form = if(options_menu, do: [options_menu: false, dynamic_form: new_dynamic_form], else: [dynamic_form: new_dynamic_form])

    extra_params = Enum.map(extra_params, fn item ->
      case item do
        {list_key, module, function, param_key, extra_input} ->
          [{list_key, apply(module, function, [params["#{param_key}"], extra_input])}]
        {list_key, module, function, param_key} ->
          [{list_key, apply(module, function, [params["#{param_key}"]])}]
        {list_key, :return_params, function} ->
          [{list_key, function.(type, params)}]
        {_list_key, _value} = record ->
          Map.new([record]) |> Map.to_list()
      end
    end)
    |> Enum.concat()


    # save dynamic_form on Draft State
    draft_id = create_and_update_draft_state(socket, Keyword.get(dynamic_form, :dynamic_form), key)

    assign_params = [basic_menu: false, alias_link: alias_link, draft_id: draft_id] ++ dynamic_form ++ extra_params

    {:noreply, assign(socket, assign_params)}
  end

  def create_and_update_draft_state(socket, dynamic_form, key) do
    case {:draft_id, is_nil(socket.assigns.draft_id)} do
      {:draft_id, true} ->
        id = Ecto.UUID.generate
        MishkaContent.Cache.ContentDraftManagement.save_by_id(id, socket.assigns.user_id, key, socket.assigns.id || :public, dynamic_form)
        id
      {:draft_id, false} ->
        MishkaContent.Cache.ContentDraftManagement.update_record(id: socket.assigns.draft_id, dynamic_form: dynamic_form)
        socket.assigns.draft_id
    end
  end

  def check_type_list(dynamic_form, new_item, type) do
    case Enum.any?(dynamic_form, fn x -> x.type == type end) do
      true ->

        {:error, :add_new_item_to_list, new_item}
      false ->

        {:ok, :add_new_item_to_list, List.insert_at(dynamic_form, -1, new_item)}
    end
  end

  def create_menu_list(menus_list, dynamic_form) do
    Enum.map(menus_list, fn menu ->
      case check_type_list(dynamic_form, %{type: menu.type, value: nil, class: menu.class}, menu.type) do
        {:ok, :add_new_item_to_list, _new_item} ->

          %{type: menu.type, value: nil, class: menu.class}

        {:error, :add_new_item_to_list, _new_item} -> nil
      end
    end)
    |> Enum.reject(fn x -> x == nil end)
  end

  def delete_item_of_list(socket, module_selected, function, id,  user_id, component, skip_list, after_condition) do
    require MishkaTranslator.Gettext
    case module_selected.delete(id) do
      {:ok, :delete, error_atom, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: activity_section_by_error_atom(error_atom),
          section_id: repo_data.id,
          action: "delete",
          priority: "medium",
          status: "info",
          user_id: Map.get(socket.assigns, :user_id)
        })

        after_condition.(id)
        paginate_assign(socket, module_selected, function, user_id, skip_list, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: socket.assigns.page)
      {:error, :delete, :forced_to_delete, _error_atom} ->
        assign(socket, [open_modal: true, component: component])
      {:error, :delete, type, _error_atom} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین رکوردی ای وجود ندارد یا ممکن است از قبل حذف شده باشد."))
      {:error, :delete, _error_atom, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف رکورد اتفاق افتاده است."))
    end
  end

  def soft_delete_item_of_list(socket, id, module_selected, after_condition, function, record_id) do
    require MishkaTranslator.Gettext
    case module_selected.delete(id) do
      {:ok, :delete, _error_atom, repo_data} ->
        after_condition.()
        new_assign = Map.new([{function, apply(module_selected, function, [Map.get(repo_data, record_id)])}]) |> Map.to_list()
        assign(socket, authors: new_assign)
      {:error, :delete, type, _error_atom} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین رکوردی ای وجود ندارد یا ممکن است از قبل حذف شده باشد."))
      {:error, :delete, _error_atom, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف رکورد اتفاق افتاده است."))
    end
  end

  def paginate_assign_filter(params, module, skip_list) when is_map(params) do
    skip_list = if(is_nil(skip_list), do: [], else: skip_list)
    Map.take(params, module.allowed_fields(:string) ++ skip_list)
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  def paginate_assign_filter(_params, _module, _skip_list), do: %{}

  def paginate_assign(socket, module, function, user_id, skip_list, params: params, page_size: count, page_number: page) do

    load_record = if user_id do
      [conditions: {page, count}, filters: paginate_assign_filter(params, module, skip_list), user_id: Map.get(socket.assigns, :auser_id)]
    else
      [conditions: {page, count}, filters: paginate_assign_filter(params, module, skip_list)]
    end

    new_assign =
      Map.new([
        {function, apply(module, function, [load_record])},
        {:page_size, page_count(count)},
        {:filters, params},
        {:page, page},
      ]) |> Map.to_list()

    assign(socket, new_assign)
  end

  defp page_count(""), do: 10
  defp page_count(count) when is_binary(count) do
    case String.to_integer(count) do
      c when c > 100 -> 100
      c when c < 10 -> 10
      c -> c
    end
  end
  defp page_count(_count), do: 10

  def activity_section_by_error_atom(error_atom) do
    [
      {:blog_author, "blog_author"}, {:category, "blog_category"}, {:post_like, "blog_post_like"},
      {:blog_link, "blog_link"}, {:post, "blog_post"}, {:blog_tag_mapper, "blog_tag_mapper"},
      {:blog_tag, "blog_tag"}, {:activity, "activity"}, {:bookmark, "bookmark"},
      {:comment_like, "comment_like"}, {:comment, "comment"}, {:notif, "notif"},
      {:subscription, "subscription"}, {:setting, "setting"}, {:permission, "permission"},
      {:role, "role"}, {:user_role, "user_role"}, {:identity, "identity"},
      {:user, "user"}
    ]
    |> Enum.find(fn {list_error_atom, _section} -> list_error_atom == error_atom end)
    |> case do
      nil -> "other"
      {_error_atom, section} -> section
    end
  end
end
