defmodule MishkaHtmlWeb.Admin.Setting.AddFieldComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col-sm-3 vazir" id="title-<%= @id %>">
        <label for="add_field_label<%= @id %>"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تیتر فیلد:") %></label>
        <button phx-click="delete_form" phx-value-type="<%= @id %>" type="button" class="btn-close" aria-label="Close"></button>
        <input type="text" id="input-name-<%= @id %>" name="input-name-<%= @id %>" class="form-control bw">
      </div>

      <div class="col-sm-4 vazir" id="value-<%= @id %>">
        <label for="add_field_label<%= @id %>"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تنظیم موردنظر:") %></label>
        <input type="text" id="input-value-<%= @id %>" name="input-value-<%= @id %>" class="form-control bw">
      </div>

      <div class="clearfix"></div>
      <div class="space30"></div>
    """
  end

end
