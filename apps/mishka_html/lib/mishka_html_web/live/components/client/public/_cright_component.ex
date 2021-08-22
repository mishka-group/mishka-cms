defmodule MishkaHtmlWeb.Client.Public.CrightComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
    <div class="space20"></div>
    <p class="cright vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ساخته شده به وسیله ترانگل © 2017–2021") %></p>
    <div class="space20"></div>
    """
  end

end
