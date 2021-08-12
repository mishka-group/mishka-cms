defmodule MishkaHtmlWeb.Admin.Form.AddTagComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="<%= @form.class %> field">
        <%= label @f , "#{@search_fields.title}:" %>
        <button phx-click="delete_form" phx-value-type="<%= @form.type %>" type="button" class="btn-close" aria-label="Close"></button>
        <%= text_input @f, String.to_atom(@form.type), class: "form-control bw", phx_keyup: "set_tag", phx_key: "Enter"%>
        <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>

        <div class="space20"></div>
        <%= for {tag, color} <- Enum.zip(@tags, Stream.cycle(
          ["bg-primary", "bg-secondary", "bg-success", "bg-danger", "bg-warning", "bg-info", "bg-dark"]
        )) do %>
        <span class="badge <%= color %> vazir admin-tag-field-size">
          <%= tag %>
          <button phx-click="delete_tag" phx-value-tag="<%= tag %>" type="button" class="btn-close delete-tag" aria-label="Close"></button>
        </span>
        <% end %>
      </div>
    """
  end
end
