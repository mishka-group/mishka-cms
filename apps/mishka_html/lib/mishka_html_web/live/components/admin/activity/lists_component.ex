defmodule MishkaHtmlWeb.Admin.Activity.ListComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list table-responsive">
        <div class="table-responsive">
            <table class="table vazir">
                <thead>
                    <tr>
                        <th scope="col td-allert warning" id="div-image"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تایم ثبت") %></th>
                        <th scope="col" id="div-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بخش") %></th>
                        <th scope="col" id="div-category"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اولویت") %></th>
                        <th scope="col" id="div-status"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "وضعیت") %></th>
                        <th scope="col" id="div-priority"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اکشن") %></th>
                        <th scope="col" id="div-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نوع") %></th>
                        <th scope="col" id="div-update"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "کاربر") %></th>
                        <th scope="col" id="div-opration"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات") %></th>
                    </tr>
                </thead>
                <tbody>
                    <%= for {item, color} <- Enum.zip(@activities, Stream.cycle(["wlist", "glist"])) do %>
                    <tr class="blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                        <td class="align-middle text-center">
                            <% time = MishkaHtmlWeb.Public.TimeConverterComponent.jalali_create(item.inserted_at) %>
                            <%= "#{time.day_number} #{time.month_name} سال #{time.year_number} در ساعت #{time.hour}:#{time.minute}:#{time.second}" %>
                        </td>
                        <td class="align-middle text-center" id="<%= "title-#{item.id}" %>">
                            <%= item.section %>
                        </td>
                        <td class="align-middle text-center">
                            <%= item.priority %>
                        </td>
                        <td class="align-middle text-center">
                            <%= item.status %>
                        </td>
                        <td class="align-middle text-center">
                            <%= item.action %>
                        </td>
                        <td class="align-middle text-center">
                            <%= item.type %>
                        </td>
                        <td class="align-middle text-center">
                            <%= if is_nil(item.user_id) do %>
                                <%= MishkaTranslator.Gettext.dgettext("html_live_component", "ندارد") %>
                            <% else %>
                                <%= live_redirect MishkaHtml.username_sanitize(item.username),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.user_id)
                                %>
                            <% end %>
                        </td>
                        <td  class="align-middle text-center" id="<%= "opration-#{item.id}" %>">
                            <a class="btn btn-outline-primary vazir", phx-click="delete" phx-value-id="<%= item.id %>"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف") %></a>

                            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "مشاهده"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminActivityLive, item.id),
                                class: "btn btn-outline-success vazir"
                            %>
                        </td>
                    </tr>
                    <% end %>
                </tbody>
            </table>
            <div class="space20"></div>
            <div class="col-sm-10">
                <%= if @activities.entries != [] do %>
                <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent ,
                                id: :pagination,
                                pagination_url: @pagination_url,
                                data: @activities,
                                filters: @filters,
                                count: @count
                %>
            </div>
            <% end %>
        </div>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
