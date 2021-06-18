defmodule MishkaHtmlWeb.Admin.Form.ConvertTitleToLinkComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="<%= @form.class %> field">
        <%= label @f , "#{MishkaHtmlWeb.AdminBlogCategoryLive.search_fields(@form.type).title}:" %>
        <button phx-click="delete_form" phx-value-type="<%= @form.type %>" type="button" class="btn-close" aria-label="Close"></button>
        <%= text_input @f, String.to_atom(@form.type), phx_keyup: "set_link", phx_key: "Enter", class: "form-control bw",  value: if !is_nil(@form.value), do: @form.value %>
        <div class="form-error-tag">
            <%= error_tag @f, String.to_atom(@form.type) %>
        </div>
        <div class="clearfix"></div>
        <div class="space10"></div>
        <span>
          <span class="badge bg-dark vazir link-converter-bdg">لینک:</span>
          <%= create_link(@link) %>
        </span>
      </div>
    """
  end

  def create_link(link) do
    if !is_nil(link) do
      Slug.slugify("#{link.value}", ignore: ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج", "چ", "ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "ک", "گ", "پ", "‍‍‍ظ", "ط", "ز", "ر", "ذ", "ژ", "د", "و", "آ", "ي"])
    end
  end
end
