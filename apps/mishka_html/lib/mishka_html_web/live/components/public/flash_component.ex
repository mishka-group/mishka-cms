defmodule MishkaHtml.Helpers.FlashComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="col-sm-12 rtl" id="live-flash" phx-hook="DeleteFlashMessage">
        <%= if live_flash(@flash, :info) do %>
          <div class="space20"></div>
          <p class="col titile-of-blog-posts alert alert-info" role="alert" id="flash_message_admin_alert" phx-click="delete_flash_message" phx-target={@myself}>
              <%= live_flash(@flash, :info) %>
          </p>
        <% end %>

        <%= if live_flash(@flash, :success) do %>
          <div class="space20"></div>
          <p class="col titile-of-blog-posts alert alert-success" role="alert" id="flash_message_admin_alert" phx-click="delete_flash_message" phx-target={@myself}>
              <%= live_flash(@flash, :success) %>
          </p>
        <% end %>

        <%= if live_flash(@flash, :warning) do %>
          <div class="space20"></div>
          <p class="col titile-of-blog-posts alert alert-warning" role="alert" id="flash_message_admin_alert" phx-click="delete_flash_message" phx-target={@myself}>
              <%= live_flash(@flash, :warning) %>
          </p>
        <% end %>

        <%= if live_flash(@flash, :error) do %>
          <div class="space20"></div>
          <p class="col titile-of-blog-posts alert alert-danger" role="alert" id="flash_message_admin_alert" phx-click="delete_flash_message" phx-target={@myself}>
              <%= live_flash(@flash, :error) %>
          </p>
        <% end %>
      </div>
    """
  end

  def handle_event("delete_flash_message", _params, socket) do
    socket =
      socket
      |> push_event("delete_flash_message", %{id: "flash_message_admin_alert"})

    {:noreply, socket}
  end
end
