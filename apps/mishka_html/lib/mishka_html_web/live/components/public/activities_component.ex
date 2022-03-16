defmodule MishkaHtmlWeb.Helpers.ActivitiesComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="col-sm-5 vazir list-activity-blog-post-and-category">
        <h3 class="admin-dashbord-h3-right-side-title vazir">
        <%= @activities_info.title %>
        </h3>
        <div class="clearfix"></div>
        <div class="space20"></div>
        <div class="clearfix"></div>
        <ul>
          <%= for item <- @activities do %>
            <li class="vazir">
              <span class="badge bg-dark">
                <.live_component
                  module={MishkaHtmlWeb.Helpers.TimeConverterComponent}
                  id={"DateTime_component_#{item.id}"}
                  span_id={"DateTime_component_#{item.id}"}
                  time={item.inserted_at},
                  detail={true}
                />
              </span>
              <%= @activities_info.section_type %>
              <span class="badge bg-warning text-dark"><%= Map.get(item.extra, @activities_info.action) %></span>
              <%= raw MishkaTranslator.Gettext.dgettext("html_live_component", "به وسیله کاربر %{user} %{action} شد",
                user: MishkaHtml.title_sanitize(Map.get(item, @activities_info.action_by) || "NO USER"),
                action: "<span class=\"badge bg-#{MishkaHtml.create_action_msg(item.action).color}\">#{MishkaHtml.create_action_msg(item.action).msg}</span>"
              ) %>
            </li>
          <% end %>
        </ul>
        <div class="clearfix"></div>
        <div class="space40"></div>
    </div>
    """
  end

  def activities(assigns, activities_info) do
    ~H"""
    <.live_component module={__MODULE__} id={"activity_component"} activities={@activities}, activities_info={activities_info} />
    """
  end
end
