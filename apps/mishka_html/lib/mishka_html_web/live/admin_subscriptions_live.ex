defmodule MishkaHtmlWeb.AdminSubscriptionsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Subscription

  def mount(_params, _session, socket) do
    if connected?(socket), do: Subscription.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: "مدیریت اشتراک ها",
        body_color: "#a29ac3cf",
        subscriptions: Subscription.subscriptions(conditions: {1, 10}, filters: %{})
      )

      {:ok, socket, temporary_assigns: [subscriptions: []]}
  end

  def handle_params(%{"page" => page, "count" => count} = params, _url, socket) do
    {:noreply,
      subscription_assign(socket, params: params["params"], page_size: count, page_number: page)
    }
  end

  def handle_params(%{"page" => page}, _url, socket) do
    {:noreply,
      subscription_assign(socket, params: socket.assigns.filters, page_size: socket.assigns.page_size, page_number: page)
    }
  end

  def handle_params(%{"count" => count} = params, _url, socket) do
    {:noreply,
      subscription_assign(socket, params: params["params"], page_size: count, page_number: 1)
    }
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params: subscription_filter(params),
            count: params["count"],
          )
      )
    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: true])}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, [open_modal: false, component: nil])}
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Subscription.delete(id) do
      {:ok, :delete, :subscription, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: "یک اشتراک از بخش: #{repo_data.section} حذف شده است."})
        subscription_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

      {:error, :delete, :forced_to_delete, :subscription} ->
        socket
        |> assign([
          open_modal: true,
          component: MishkaHtmlWeb.Admin.Subscription.DeleteErrorComponent
        ])

      {:error, :delete, type, :subscription} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, "چنین مجموعه ای وجود ندارد یا ممکن است از قبل حذف شده باشد.")

      {:error, :delete, :subscription, _repo_error} ->
        socket
        |> put_flash(:error, "خطا در حذف مجموعه اتفاق افتاده است.")
    end

    {:noreply, socket}
  end

  def handle_info({:subscription, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        subscription_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )
       _ ->  socket
    end

    {:noreply, socket}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminSubscriptionsLive"})
    {:noreply, socket}
  end

  defp subscription_filter(params) when is_map(params) do
    Map.take(params, Subscription.allowed_fields(:string) ++ ["full_name"])
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp subscription_filter(_params), do: %{}

  defp subscription_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          subscriptions: Subscription.subscriptions(conditions: {page, count}, filters: subscription_filter(params)),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end
end
