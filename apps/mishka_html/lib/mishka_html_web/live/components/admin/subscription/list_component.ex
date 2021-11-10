defmodule MishkaHtmlWeb.Admin.Subscription.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="col bw admin-blog-post-list" >
        <div class="table-responsive">
          <table class="table vazir">
            <thead>
                <tr>
                  <th scope="col" id="div-image"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بخش") %></th>
                  <th scope="col" id="div-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "وضعیت") %></th>
                  <th scope="col" id="div-category"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "کاربر") %></th>
                  <th scope="col" id="div-status"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ثبت") %></th>
                  <th scope="col" id="div-priority"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انقضا") %></th>
                  <th scope="col" id="div-opration"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات") %></th>
                </tr>
            </thead>
            <tbody>
                <%= for {item, color} <- Enum.zip(@subscriptions, Stream.cycle(["wlist", "glist"])) do %>
                  <tr class={"blog-list vazir #{if(color == "glist", do: "odd-list-of-blog-posts", else: "")}"}>
                      <td class="align-middle text-center" id={"title-#{item.id}"}>
                        <%
                            field = Enum.find(MishkaHtmlWeb.AdminSubscriptionLive.basic_menu_list, fn x -> x.type == "section" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.section end)
                        %>

                        <%= title %>
                      </td>
                      <td class="align-middle text-center">
                        <%
                            field = Enum.find(MishkaHtmlWeb.AdminSubscriptionLive.basic_menu_list, fn x -> x.type == "status" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.status end)
                        %>
                        <%= title %>
                      </td>
                      <td class="align-middle text-center">
                        <span class="badge rounded-pill bg-dark"><%= item.user_full_name %></span>
                      </td>
                      <td class="align-middle text-center">
                        <.live_component module={MishkaHtmlWeb.Public.TimeConverterComponent} id={"inserted-#{item.id}-component"} span_id={"inserted-#{item.id}-component"} time={item.inserted_at} />
                      </td>

                      <td class="align-middle text-center">
                        <%= if is_nil(item.expire_time) do %>
                        <span class="badge rounded-pill bg-secondary"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ندارد") %> </span>
                        <% else %>
                        <.live_component module={MishkaHtmlWeb.Public.TimeConverterComponent} id={"expire_time-#{item.id}-component"} span_id={"expire_time-#{item.id}-component"} time={item.expire_time} />
                        <% end %>
                      </td>

                      <td  class="align-middle text-center" id={"opration-#{item.id}"}>
                        <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "ویرایش"),
                        to: Routes.live_path(@socket, MishkaHtmlWeb.AdminSubscriptionLive, id: item.id),
                        class: "btn btn-outline-info vazir"
                        %>
                        <a class="btn btn-outline-danger vazir" phx-click="delete" phx-value-id={item.id}><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف") %></a>
                      </td>
                  </tr>
                <% end %>
            </tbody>
          </table>
          <div class="space20"></div>
          <div class="col-sm-10">
              <%= if @subscriptions.entries != [] do %>
                <.live_component module={MishkaHtmlWeb.Public.PaginationComponent} id={:pagination} pagination_url={@pagination_url} data={@subscriptions} filters={@filters} count={@count} />
              <% end %>
          </div>
        </div>
      </div>
    """
  end
end
