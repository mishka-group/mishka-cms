defmodule MishkaHtmlWeb.Admin.PaginationComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <nav aria-label="Page navigation example">
        <ul class="pagination justify-content-center pagination-lg">
            <li class="page-item">
                <a class="page-link paginationlist" href="#">اولین</a>
            </li>
            <li class="page-item">
                <a class="page-link paginationlist" href="#">آخرین</a>
            </li>
            <li class="page-item"><a class="page-link paginationlist" href="#">1</a></li>
            <li class="page-item active"><a class="page-link paginationlist" href="#">2</a></li>
            <li class="page-item"><a class="page-link paginationlist" href="#">3</a></li>
            <li class="page-item">
                <a class="page-link paginationlist" href="#">بعدی</a>
            </li>
            <li class="page-item">
                <a class="page-link paginationlist" href="#">قبلی</a>
            </li>
        </ul>
      </nav>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end

end
