defmodule MishkaHtmlWeb.Admin.Form.SelectComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class={"#{@form.class} field"}>
        <%= label @f , "#{@search_fields.title}:" %>
        <button phx-click="delete_form" phx-value-type={@form.type} type="button" class="btn-close" aria-label="Close"></button>
        <%= select @f, String.to_atom(@form.type),
          @search_fields.options,
          class: "form-select",
          selected: "#{@form.value}"
        %>
        <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>
      </div>
    """
  end
end
