defmodule MishkaHtmlWeb.Admin.Form.TextAreaComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="<%= @form.class %> field">
        <%= label @f , "#{MishkaHtmlWeb.AdminBlogCategoryLive.search_fields(@form.type).title}:" %>
        <button phx-click="delete_form" phx-value-type="<%= @form.type %>" type="button" class="btn-close" aria-label="Close"></button>
        <%= textarea @f, String.to_atom(@form.type), class: "form-control bw", style: "height: 305px", value: if !is_nil(@form.value), do: @form.value %>
        <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>
      </div>
    """
  end
end
