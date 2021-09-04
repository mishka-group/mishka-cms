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
end
