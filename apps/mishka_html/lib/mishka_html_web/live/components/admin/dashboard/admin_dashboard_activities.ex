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
        <%= for {item, color} <- Enum.zip(@activities, Stream.cycle(["primary", "secondary", "success", "danger", "warning"])) do %>
        <div class="alert alert-<%= error_status(item.status, item.inserted_at).color %>" role="alert">
          <%= error_status(item.status, item.inserted_at).msg %>
        </div>
        <%= end %>
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
      :error -> %{color: "danger", msg: "خطای سیستمی #{time.day_number} #{time.month_name} ساعت #{time.hour}:#{time.minute}"}
      :info -> %{color: "secondary", msg: "اطلاعات عمومی #{time.day_number} #{time.month_name} ساعت #{time.hour}:#{time.minute}"}
      :warning -> %{color: "warning", msg: "هشدار سیستمی #{time.day_number} #{time.month_name} ساعت #{time.hour}:#{time.minute}"}
      :report -> %{color: "primary", msg: "گزارش کاربری #{time.day_number} #{time.month_name} ساعت #{time.hour}:#{time.minute}"}
      :throw -> %{color: "danger", msg: "خطای سیستمی #{time.day_number} #{time.month_name} ساعت #{time.hour}:#{time.minute}"}
      :exit -> %{color: "danger", msg: "توقف سیستم #{time.day_number} #{time.month_name} ساعت #{time.hour}:#{time.minute}"}
    end
  end
end
