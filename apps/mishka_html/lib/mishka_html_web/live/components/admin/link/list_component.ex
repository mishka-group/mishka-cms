defmodule MishkaHtmlWeb.Admin.User.ListComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">


        <div class="table-responsive">
            <table class="table vazir">
                <thead>
                    <tr>
                        <th scope="col" id="div-image"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تصویر") %></th>
                        <th scope="col" id="div-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام کامل") %></th>
                        <th scope="col" id="div-category"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام کاربری") %></th>
                        <th scope="col" id="div-status"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ایمیل") %></th>
                        <th scope="col" id="div-priority"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "وضعیت") %></th>
                        <th scope="col" id="div-update"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ثبت") %></th>
                        <th scope="col" id="div-opration"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات") %></th>
                    </tr>
                </thead>
                <tbody>
                    <%= for {item, color} <- Enum.zip(@users, Stream.cycle(["wlist", "glist"])) do %>
                    <tr class="blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                        <td class="align-middle col-sm-2 admin-list-img">
                            <img src="/images/no-user-image.jpg" alt="<%= item.full_name %>">
                        </td>
                        <td class="align-middle text-center" id="<%= "title-#{item.id}" %>">
                            <%= live_redirect "#{MishkaHtml.full_name_sanitize(item.full_name)}",
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.id)
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_redirect "#{MishkaHtml.username_sanitize(item.username)}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.id)
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%= MishkaHtml.email_sanitize(item.email) %>
                        </td>
                        <td class="align-middle text-center">
                            <%
                                field = Enum.find(MishkaHtmlWeb.AdminUserLive.basic_menu_list, fn x -> x.type == "status" end)
                                {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.status end)
                            %>
                            <%= title %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                                span_id: "inserted-at-#{item.id}-component",
                                time: item.inserted_at
                            %>
                        </td>
                        <td  class="align-middle text-center" id="<%= "opration-#{item.id}" %>">

                                <a class="btn btn-outline-primary vazir" phx-click="delete" phx-value-id="<%= item.id %>">حذف</a>

                            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "ویرایش"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.id),
                                class: "btn btn-outline-danger vazir"
                            %>
                            <% user_role = item.roles %>
                            <div class="clearfix"></div>
                            <div class="space20"></div>
                            <div class="col">
                                <label for="country" class="form-label">
                                <%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب دسترسی") %>
                                </label>
                                <form  phx-change="search_role">
                                    <input class="form-control" type="text" placeholder="<%= MishkaTranslator.Gettext.dgettext("html_live_component", "جستجوی پیشرفته") %>" name="name">
                                </form>
                                <form  phx-change="user_role">
                                    <input type="hidden" value="<%= item.id %>" name="user_id">
                                    <select class="form-select" id="role" name="role" size="2" style="min-height: 150px;">
                                    <option value="delete_user_role"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بدون دسترسی") %></option>
                                    <%= for item <- @roles.entries do %>
                                        <option value="<%= item.id %>" <%= if(!is_nil(user_role) and item.id == user_role.id, do: "selected") %>><%= item.name %></option>
                                    <% end %>
                                    </select>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% end %>
                </tbody>
            </table>
            <div class="space20"></div>
            <div class="col-sm-10">
                <%= if @users.entries != [] do %>
                <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent ,
                                id: :pagination,
                                pagination_url: @pagination_url,
                                data: @users,
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
