defmodule MishkaHtml.Helpers.SearchComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~H"""
      <div>
        <div class="clearfix"></div>
        <div class="col space30"> </div>
        <hr>
        <div class="clearfix"></div>
        <div class="col space30"> </div>
        <h2 class="vazir">
        <%= MishkaTranslator.Gettext.dgettext("html_live_component", "جستجوی پیشرفته") %>
        </h2>
        <div class="clearfix"></div>
        <div class="col space30"> </div>
        <div class="col space10"> </div>
        <form  phx-change="search">
          <div class="row vazir admin-list-search-form">
                <%= for item <- search_html(assigns, @fields) do %>
                  <%= item %>
                <% end %>
                <div class="col-md-1">
                  <label for="lable-form-text-count" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تعداد") %></label>
                  <div class="col space10"> </div>
                  <select class="form-select" id="countrecords" name="count">
                    <option value="10"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                    <option value="20"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "%{count} عدد", count: 20) %></option>
                    <option value="30"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "%{count} عدد", count: 30) %></option>
                    <option value="40"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "%{count} عدد", count: 40) %></option>
                  </select>
                </div>
                <div class="col-sm-2">
                  <label for="country" class="form-label vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات سریع") %></label>
                  <div class="col space10"> </div>
                  <button type="button" class="vazir col-sm-8 btn btn-primary reset-admin-search-btn" phx-click="reset"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ریست") %></button>
                </div>
          </div>
        </form>
      </div>
    """
  end

  def search_html(assigns, section_fields) do
    section_fields
    |> Enum.filter(fn x -> x.search end)
    |> Enum.map(fn field -> search_html(field.form, field, assigns) end)
  end

  def search_html("select", field, assigns) do
    ~H"""
      <div class="col-md-1">
        <label for={"select-field-#{field.type}"} class="form-label"><%= field.title %></label>
        <div class="col space10"> </div>
        <select class="form-select" name={field.type} id="SearchStatus">
          <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
          <%= for {option_title, option_value} <- field.options do %>
            <option value={option_value}><%= option_title %></option>
          <% end %>
        </select>
      </div>
    """
  end

  def search_html("text", field, assigns) do
    ~H"""
      <div class="col">
        <label for={"lable-form-text-#{field.type}"} class="form-label"><%= field.title %></label>
        <div class="space10"> </div>
        <input type="text" class="title-input-text form-control" name={field.type}>
        <div class="col space10"> </div>
      </div>
    """
  end
end
