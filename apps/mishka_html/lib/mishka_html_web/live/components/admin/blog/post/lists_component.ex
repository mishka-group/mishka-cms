defmodule MishkaHtmlWeb.Admin.Blog.Post.ListComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list table-responsive">
        <div class="table-responsive">
            <table class="table vazir">
                <thead>
                    <tr>
                        <th scope="col td-allert warning" id="div-image"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تصویر") %></th>
                        <th scope="col" id="div-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تیتر") %>تیتر</th>
                        <th scope="col" id="div-category"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مجموعه") %></th>
                        <th scope="col" id="div-status"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "وضعیت") %></th>
                        <th scope="col" id="div-priority"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اولویت") %></th>
                        <th scope="col" id="div-update"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "به روز رسانی") %></th>
                        <th scope="col" id="div-opration"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات") %></th>
                    </tr>
                </thead>
                <tbody>
                    <%= for {item, color} <- Enum.zip(@posts, Stream.cycle(["wlist", "glist"])) do %>
                    <tr class="blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                        <td class="col-sm-2 admin-list-img">
                            <img src="<%= item.main_image %>" alt="<%= item.title %>">
                        </td>
                        <td class="align-middle text-center" id="<%= "title-#{item.id}" %>">
                            <%= live_redirect "#{MishkaHtml.title_sanitize(item.title)}",
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogPostLive, id: item.id)
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_redirect "#{MishkaHtml.title_sanitize(item.category_title)}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.category_id)
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%
                            field = Enum.find(MishkaHtmlWeb.AdminBlogPostLive.basic_menu_list, fn x -> x.type == "status" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.status end)
                            %>
                            <span class="badge bg-info"><%= title %></span>
                        </td>
                        <td class="align-middle text-center">
                            <%
                            field = Enum.find(MishkaHtmlWeb.AdminBlogPostLive.basic_menu_list, fn x -> x.type == "priority" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.priority end)
                            %>
                            <span class="badge bg-success"><%= title %></span>
                        </td>
                        <td class="align-middle text-center">
                        <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                        span_id: "updated_at-#{item.id}-component",
                        time: item.updated_at
                        %>
                        </td>
                        <td  class="align-middle text-center" id="<%= "opration-#{item.id}" %>">
                            <a class="btn btn-outline-primary vazir", phx-click="delete" phx-value-id="<%= item.id %>"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف") %></a>
                            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "نظرات"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminCommentsLive, section_id: item.id),
                                class: "btn btn-outline-success vazir"
                            %>
                            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "حذف کامل"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id),
                                class: "btn btn-outline-danger vazir"
                            %>
                            <div class="space10"></div>
                            <div class="clearfix"></div>
                            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "نویسندگان"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogPostAuthorsLive, item.id),
                                class: "btn btn-outline-secondary vazir"
                            %>
                            <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "برچسب ها"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogPostTagsLive, item.id),
                                class: "btn btn-outline-warning vazir"
                            %>
                        </td>
                    </tr>
                    <% end %>
                </tbody>
            </table>
            <div class="space20"></div>
            <div class="col-sm-10">
                <%= if @posts.entries != [] do %>
                <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent ,
                                id: :pagination,
                                pagination_url: @pagination_url,
                                data: @posts,
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
