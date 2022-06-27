defmodule MishkaHtmlWeb.Admin.Dashboard.LastNotifComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="col admin-home-toos-left vazir">
        <h3>
          <div class="row">
            <span class="col-sm-1 iconly-bulkDanger"><span class="path1"></span><span class="path2"></span></span>

            <span class="col admin-home-last-notif-title rtl"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "آخرین اطلاع رسانی ها") %></span>
            <div class="space20"></div>
            <ul class="admin-home-ul-of-lists vazir">
              <%= for notif <- @notifs do %>
                <li><%= notif_summary(notif) %></li>
              <% end %>
            </ul>
            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_templates", "نمایش همه اعلانات"), to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogNotifsLive), class: "col-sm-12 btn btn-outline-secondary btn-lg" %>
          </div>
        </h3>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end

  def notif_summary(notif) when notif.section == :public,
    do: MishkaTranslator.Gettext.dgettext("html_live_templates", "اطلاع رسانی عمومی و انبوه")

  def notif_summary(notif) when notif.section == :user_only,
    do: MishkaTranslator.Gettext.dgettext("html_live_templates", "اطلاع رسانی مختص به کاربر")

  def notif_summary(notif) when notif.section == :admin,
    do: MishkaTranslator.Gettext.dgettext("html_live_templates", "اطلاع رسانی مخصوص مدیریت")

  def notif_summary(_notif),
    do: MishkaTranslator.Gettext.dgettext("html_live_templates", "اطلاع رسانی مخصوص به بخش")
end
