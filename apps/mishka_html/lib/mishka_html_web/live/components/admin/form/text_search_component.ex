defmodule MishkaHtmlWeb.Admin.Form.TextSearchComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="<%= @form.class %> field">
        <%= label @f , "#{MishkaHtmlWeb.AdminBlogCategoryLive.search_fields(@form.type).title}:" %>
        <button phx-click="delete_form" phx-value-type="<%= @form.type %>" type="button" class="btn-close" aria-label="Close"></button>
        <%= text_input @f, String.to_atom(@form.type), class: "form-control bw",  value: if(!is_nil(@form.value), do: @form.value), id: "text_search", phx_hook: "TextSearch" %>
        <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>



        <%= if @search != [] do %>
          <div class="list-group" id="list_of_text_search">
          <div class="space20"></div>
          <button phx-click="close_text_search" type="button" class="btn-close" aria-label="Close"></button>
          <div class="space10"></div>
            <%= for {item, color} <- Enum.zip(@search, Stream.cycle(["warning", "info", "danger", "success", "primary"])) do %>
              <a class="list-group-item list-group-item-<%= color %>" aria-current="true" id="<%= item.id %>" phx-click="text_search_click" phx-value-id="<%= item.id %>">
                <div class="d-flex w-100 justify-content-between">
                  <h4 class="mb-1"><%= item.title %></h4>
                  <small>
                  <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                  %>
                  </small>
                </div>
                <small class="text-muted">
                  <%= item.short_description %>
                </small>
              </a>
            <% end %>
          </div>

          <div class="space30"></div>
        <% end %>

      </div>
    """
  end
end
