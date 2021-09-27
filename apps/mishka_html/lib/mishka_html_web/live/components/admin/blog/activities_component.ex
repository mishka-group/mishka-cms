defmodule MishkaHtmlWeb.Admin.Blog.ActivitiesComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
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
              <%= section_type(@type) %>
              <span class="badge bg-warning text-dark"><%= Map.get(item.extra, :title) || Map.get(item.extra, "title") || MishkaTranslator.Gettext.dgettext("html_live_component", "بدون تیتر") %></span>
              <%= MishkaTranslator.Gettext.dgettext("html_live_component", "به وسیله کاربر:") %>
              <%= item.full_name %>
              <span class="badge bg-<%= create_action_msg(item.action).color %>"><%= create_action_msg(item.action).msg %></span>
              شد.
            </li>
          <%= end %>
        </ul>
        <div class="clearfix"></div>
        <div class="space40"></div>
        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
            <button type="button" class="btn btn-outline-danger">برای دیدن اطلاعات بیشتر کلیک کنید</button>
        </div>
    </div>
    """
  end

  defp create_action_msg(action) do
    case action do
      :add -> %{color: "success", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "درست")}
      :edit -> %{color: "primary", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "ویرایش")}
      :delete -> %{color: "danger", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "حذف با پرچم")}
      :destroy -> %{color: "dark", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "حذف کامل")}
      :read -> %{color: "info", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "خوانده")}
      :send_request -> %{color: "light", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "ارسال درخواست")}
      :receive_request -> %{color: "light", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "دریافت درخواست")}
      :other -> %{color: "warning", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "مورد عملیات دیگر")}
      :auth -> %{color: "secondary", msg: MishkaTranslator.Gettext.dgettext("html_live_component", "مدیریت دسترسی")}
    end
  end
  defp create_insterted_at_time_string(inserted_at) do
    time = MishkaHtmlWeb.Public.TimeConverterComponent.jalali_create(inserted_at)
    MishkaTranslator.Gettext.dgettext("html_live_component", "%{day_number} %{month_name} ساعت %{hour}:%{minute}:%{second}", day_number: time.day_number, month_name: time.month_name, hour: time.hour, minute: time.minute, second: time.second)
  end

  defp section_type(type) when type == "blog_post" do
    MishkaTranslator.Gettext.dgettext("html_live_component", "مطلب")
  end

  defp section_type(type) when type == "blog_category" do
    MishkaTranslator.Gettext.dgettext("html_live_component", "مجموعه")
  end
end
