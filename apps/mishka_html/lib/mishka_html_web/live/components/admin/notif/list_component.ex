defmodule MishkaHtmlWeb.Admin.Notif.ListComponent do
    use MishkaHtmlWeb, :live_component


    def render(assigns) do
      ~H"""
        <div class="col bw admin-notif-section">
          <div class="space20"></div>
          <div class="row">
              <%= for item <- @notifs do %>
                <div class="col-sm-6 admin-notif-list vazir">
                  <h3>توضیحات کوتاه:</h3>
                  <div class="row">
                    <div class="col-sm-10 admin-notif-short-dis">
                    <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_templates", "%{title}", title: item.title), to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogNotifLive, id: item.id, type: "show"), class: "admin-notif-title-link" %>
                    </div>

                    <div class="col-sm">
                      <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_templates", "ویرایش"), to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogNotifLive, id: item.id, type: "edit"), class: "btn btn-outline-secondary mb-2 vazir" %>

                      <a class="btn btn-outline-primary mb-2 vazir" phx-click="delete" phx-value-id={item.id}><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف") %></a>
                    </div>
                  </div>
                  <div class="space10"></div>

                  <span class="notif-admin-list-badge badge bg-dark">وضعیت: <%= item.status %></span>
                  <span class="notif-admin-list-badge badge bg-danger">بخش: <%= item.section %></span>
                  <span class="notif-admin-list-badge badge bg-success">نوع: <%= item.type %></span>
                  <span class="notif-admin-list-badge badge bg-primary">هدف: <%= item.target %></span>
                  <%= if !is_nil(item.user_id) do %>
                    <span class="notif-admin-list-badge badge bg-danger">
                      <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_templates", "دیدن کاربر"), to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.user_id), class: "admin-notif-user-link" %>
                    </span>
                  <% end %>
                  <hr>
                </div>
              <% end %>
            </div>

            <%= if @notifs.entries == [] do %>
                <div class="clearfix"></div>
                <div class="space30"></div>
                <div class="col-sm-12 admin-there-is-no-field vazir">
                <div class="space30"></div>
                    <span class="admin-there-is-no-field-text"><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "هیچ اعلانی به لیست اضافه نشده است") %></span>
                    <div class="space10"></div>
                    <span class="text-muted"><%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در بخش مدیریت می توانید اعلان عمومی یا اعلان مختص به یک کاربر را بسازید.") %></span>
                    <div class="space30"></div>
                </div>
                <div class="clearfix"></div>
            <% end %>

            <%= if @notifs.entries != [] do %>
            <.live_component module={MishkaHtmlWeb.Public.PaginationComponent} id={:pagination} pagination_url={@pagination_url} data={@notifs} filters={@filters} count={@count} />
            <% end %>
        </div>
      """
    end

  end
