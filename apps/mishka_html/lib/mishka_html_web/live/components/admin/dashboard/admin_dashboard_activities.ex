defmodule MishkaHtmlWeb.Admin.Dashboard.ActivitiesComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
    <div class="col-sm-5 cms-block-menu-center">
      <div class="col activity-menu vazir">
        <h3 class="text-center activities-title-admin-home"  phx-click="activities" phx-target="<%= @myself %>">
          <span class="activities-title-admin-home-text"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "لاگ لحظه ای") %></span>

          <a class="iconly-bulkArrow---Right-Square"><span class="path1"></span><span class="path2"></span></a>
        </h3>
        <div class="space20"></div>
        <%= for item <- @activities do %>
          <%= live_redirect to: Routes.live_path(@socket, MishkaHtmlWeb.AdminActivityLive, item.id), class: "admin-home-activities-link", replace: false do %>
            <div class="alert alert-<%= error_status(item.status, item.inserted_at).color %>" role="alert"><%= error_status(item.status, item.inserted_at).msg %></div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("activities", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminActivitiesLive))}
  end

  defp error_status(status, inserted_at) do
    time = MishkaHtmlWeb.Public.TimeConverterComponent.jalali_create(inserted_at)
    case status do
      :error -> %{color: "danger", msg: MishkaTranslator.Gettext.dgettext("html_live_templates", "خطای سیستمی %{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)}
      :info -> %{color: "info", msg: MishkaTranslator.Gettext.dgettext("html_live_templates", "اطلاعات عمومی %{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)}
      :warning -> %{color: "warning", msg: MishkaTranslator.Gettext.dgettext("html_live_templates", "هشدار سیستمی %{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)}
      :report -> %{color: "primary", msg: MishkaTranslator.Gettext.dgettext("html_live_templates", "گزارش کاربری %{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)}
      :throw -> %{color: "dark", msg: MishkaTranslator.Gettext.dgettext("html_live_templates", "خطای سیستمی %{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)}
      :exit -> %{color: "secondary", msg: MishkaTranslator.Gettext.dgettext("html_live_templates", "توقف سیستم %{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)}
    end
  end
end
