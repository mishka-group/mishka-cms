defmodule MishkaHtmlWeb.Client.BlogPost.SubComment do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="phx-modal"
         phx-window-keydown="close_modal"
         phx-key="escape"
         phx-capture-click="close_modal">
      <div class="phx-modal-content col-sm-4">

      <div class="client-sub-card-modal col vazir rtl">

          <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">پاسخ به نظر:
            <%= @sub_comment.full_name %>
            </h5>
          </div>
          <div class="modal-body">
            <%= @sub_comment.description %>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-danger" phx-click="close_modal">بستن</button>
          </div>
        </div>
      </div>

      </div>
    </div>
    """
  end
end
