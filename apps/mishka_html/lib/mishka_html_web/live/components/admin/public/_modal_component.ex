defmodule MishkaHtmlWeb.Admin.Public.ModalComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="phx-modal"
         phx-window-keydown="close_modal"
         phx-key="escape"
         phx-capture-click="close_modal">
      <div class="phx-modal-content col-sm-4">
        <.live_component module={@component} id={:live_modal_status} />
      </div>
    </div>
    """
  end
end
