defmodule MishkaHtmlWeb.Admin.Form.EditorComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div>
        <div id="editor-main-dive" class="col-sm-12 editor-diver vazir rtl" phx-update="ignore">
            <div id="editor" phx-hook="Editor" class="bw vazir rtl" phx-update="ignore"></div>
        </div>
        <div class="form-error-tag vazir" id="editor-tag-error">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>
        <div class="space20"></div>
      </div>
    """
  end
end
