defmodule MishkaHtmlWeb.Admin.Form.TextComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="<%= @form.class %> field">
        <%= label @f , "#{@search_fields.title}:" %>
        <button phx-click="delete_form" phx-value-type="<%= @form.type %>" type="button" class="btn-close" aria-label="Close"></button>
        <%= text_input @f, String.to_atom(@form.type), class: "form-control bw",  value: if !is_nil(@form.value), do: @form.value %>
        <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>
      </div>
    """
  end
end
