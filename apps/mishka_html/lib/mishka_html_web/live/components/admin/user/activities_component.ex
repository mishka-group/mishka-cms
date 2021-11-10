defmodule MishkaHtmlWeb.Admin.User.ActivitiesComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="col-sm-5 vazir list-activity-blog-post-and-category">
          <h3 class="admin-dashbord-h3-right-side-title vazir">
          <%= MishkaTranslator.Gettext.dgettext("html_live_component", "آخرین فعالیت ها در تولید محتوا") %>
          </h3>
          <div class="clearfix"></div>
          <div class="space20"></div>
          <div class="clearfix"></div>
          <ul>
            <%= for item <- @activities do %>
              <li class="vazir">
                <span class="badge bg-dark">
                <%= create_insterted_at_time_string(item.inserted_at) %>
                </span>
                <%= MishkaTranslator.Gettext.dgettext("html_live_component", "کاربر") %>
                <span class="badge bg-warning text-dark"><%= Map.get(item.extra, :full_name) || Map.get(item.extra, "full_name") || MishkaTranslator.Gettext.dgettext("html_live_component", "بدون نام") %></span>
                <%= MishkaTranslator.Gettext.dgettext("html_live_component", "به وسیله کاربر:") %>
                <%= item.full_name %>
                <span class={"badge bg-#{MishkaHtml.create_action_msg(item.action).color}"}><%= MishkaHtml.create_action_msg(item.action).msg %></span>
                شد.
              </li>
            <% end %>
          </ul>
          <div class="clearfix"></div>
          <div class="space40"></div>
          <div class="d-grid gap-2 d-md-flex justify-content-md-end">
              <button type="button" class="btn btn-outline-danger">برای دیدن اطلاعات بیشتر کلیک کنید</button>
          </div>
      </div>
    """
  end

  defp create_insterted_at_time_string(inserted_at) do
    time = MishkaHtmlWeb.Public.TimeConverterComponent.jalali_create(inserted_at)
    MishkaTranslator.Gettext.dgettext("html_live_component", "%{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)
  end
end
