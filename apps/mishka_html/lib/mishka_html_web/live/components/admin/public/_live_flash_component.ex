defmodule MishkaHtmlWeb.Admin.Public.LiveFlashComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col-sm-12 rtl" id="live-flash">
        <%= if live_flash(@flash, :info) do %>
          <div class="space20"></div>
          <p id="<%= Ecto.UUID.generate %>" class="col titile-of-blog-posts alert alert-info" role="alert" phx-click="lv:clear-flash" phx-value-key="info">
              <%= live_flash(@flash, :info) %>
          </p>
        <% end %>

        <%= if live_flash(@flash, :success) do %>
          <div class="space20"></div>
          <p id="<%= Ecto.UUID.generate %>" class="col titile-of-blog-posts alert alert-success" role="alert" phx-click="lv:clear-flash" phx-value-key="success">
              <%= live_flash(@flash, :success) %>
          </p>
        <% end %>

        <%= if live_flash(@flash, :warning) do %>
          <div class="space20"></div>
          <p id="<%= Ecto.UUID.generate %>" class="col titile-of-blog-posts alert alert-warning" role="alert" phx-click="lv:clear-flash" phx-value-key="warning">
              <%= live_flash(@flash, :warning) %>
          </p>
        <% end %>

        <%= if live_flash(@flash, :error) do %>
          <div class="space20"></div>
          <p id="<%= Ecto.UUID.generate %>" class="col titile-of-blog-posts alert alert-danger" role="alert" phx-click="lv:clear-flash" phx-value-key="error">
              <%= live_flash(@flash, :error) %>
          </p>
        <% end %>
      </div>
    """
  end
end
