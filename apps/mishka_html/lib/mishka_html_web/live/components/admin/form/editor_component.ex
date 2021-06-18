defmodule MishkaHtmlWeb.Admin.Form.EditorComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="editor-main-dive" class="col-sm-12 editor-diver" phx-update="ignore">
        <div id="editor" phx-hook="Editor" class="bw" phx-update="ignore"></div>
    </div>
    <div class="form-error-tag" id="editor-tag-error">
        <%= error_tag @f, String.to_atom(@form.type) %>
    </div>
    """
  end
end
