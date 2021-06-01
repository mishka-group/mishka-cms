defmodule MishkaHtmlWeb.Admin.Public.SearchComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <form class="col d-flex">
        <input class="form-control me-2 ltr" type="search" placeholder="Search" aria-label="Search">
      </form>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
