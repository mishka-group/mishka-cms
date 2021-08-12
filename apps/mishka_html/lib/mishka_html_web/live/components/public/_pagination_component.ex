defmodule MishkaHtmlWeb.Public.PaginationComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <nav aria-label="Page navigation example" phx-hook="Paginate">
        <ul class="pagination justify-content-center pagination-lg">
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="1" phx-target="<%= @myself %>">اولین</a>
            </li>
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= @data.total_pages %>" phx-target="<%= @myself %>">آخرین</a>
            </li>
            <%= for item <- navigation(@data.page_number, @data.total_pages) do %>
            <li class="page-item <%= if(@data.page_number == item, do: "active") %>">
              <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= item %>" phx-target="<%= @myself %>"><%= item %></a>
            </li>
            <% end %>
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= if(@data.page_number + 1 <= @data.total_pages, do: @data.page_number + 1, else: @data.page_number) %>" phx-target="<%= @myself %>">بعدی</a>
            </li>
            <li class="page-item">
                <a class="page-link paginationlist" phx-click="select-per-page" phx-value-page="<%= if(@data.page_number > 1, do: @data.page_number - 1, else: 1) %>" phx-target="<%= @myself %>">قبلی</a>
            </li>
        </ul>
      </nav>
    """
  end

  def handle_event("select-per-page", %{"page" => page}, socket) do
    socket = case Map.get(socket.assigns, :alias_link) do
      nil ->
        push_patch(socket,
          to:
            Routes.live_path(
              socket,
              socket.assigns.pagination_url,
              page: page,
              params: socket.assigns.filters,
              count: socket.assigns.count
            )
        )
        |> push_event("jump_to_top_page", %{})

      alias_link ->
        push_patch(socket,
          to:
            Routes.live_path(
              socket,
              socket.assigns.pagination_url,
              alias_link,
              page: page,
              params: socket.assigns.filters,
              count: socket.assigns.count
            )
        )
        |> push_event("jump_to_top_page", %{})
    end



    {:noreply, socket}
  end

  def navigation(page_router_number, total_pages) do
    start_number = compare_with_pagenumber(integer_geter(page_router_number), total_pages)
    (start_number - 3)..(start_number + 5)
    |> Enum.to_list
    |> Enum.filter(fn(x) -> x <= total_pages end)
    |> Enum.filter(fn(x) -> x > 0 end)
  end

  @spec compare_with_pagenumber(any, any) :: any
  def compare_with_pagenumber(page_router_number, total_pages) when page_router_number <= total_pages do
    page_router_number
    |> integer_geter
  end

  def compare_with_pagenumber(_page_router_number, _total_pages), do: 1

  def integer_geter(string) do
    output = "#{string}"
    |> String.replace(~r/[^\d]/, "")
    if output == "", do: 1, else: String.to_integer(output)
  end

end
