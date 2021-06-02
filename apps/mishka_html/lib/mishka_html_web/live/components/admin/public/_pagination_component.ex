defmodule MishkaHtmlWeb.Admin.PaginationComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <nav aria-label="Page navigation example">
        <ul class="pagination justify-content-center pagination-lg">
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="1" phx-target="<%= @myself %>">اولین</a>
            </li>
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= @data.total_pages %>" phx-target="<%= @myself %>">آخرین</a>
            </li>

            <%= for item <- Enum.shuffle(1.. @data.total_pages) |> Enum.sort do %>
            <li class="page-item <%= if(@data.page_number == item, do: "active") %>">
              <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= item %>" phx-target="<%= @myself %>"><%= item %></a>
            </li>
            <%= end %>

            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= if(@data.page_number + 1 <= @data.total_pages, do: @data.page_number + 1, else: @data.page_number) %>" phx-target="<%= @myself %>">بعدی</a>
            </li>
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= if(@data.total_pages > 1, do: @data.page_number - 1, else: 1) %>" phx-target="<%= @myself %>">قبلی</a>
            </li>
        </ul>
      </nav>
    """
  end

  def handle_event("select-per-page", %{"page" => page}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            socket.assigns.pagination_url,
            page: page,
          )
      )

    {:noreply, socket}
  end
end
