defmodule MishkaHtmlWeb.Admin.User.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col-sm-1 titile-of-blog-posts alert alert-primary" id="div-image">
                    تصویر
                </div>

                <div class="col-sm-2 titile-of-blog-posts alert alert-warning" id="div-title">
                    نام کامل
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-success" id="div-show">
                    نام کاربری
                </div>

                <div class="col titile-of-blog-posts alert alert-danger" id="div-status">
                    ایمیل
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-success" id="div-insert">
                    وضعیت
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-info" id="div-update">
                    ثبت
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-warning" id="div-update">
                    آپدیت
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-dark" id="div-opreation">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@users, Stream.cycle(["wlist", "glist"])) do %>
                <div phx-update="append" id="<%= item.id %>" class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col-sm-1" id="<%= "image-#{item.id} "%>">
                        <div class="col"
                            style="min-height: 100px;
                            background-image: url(/images/no-user-image.jpg);
                            background-repeat: no-repeat;
                            box-shadow: 1px 1px 8px #dadada;background-size: cover;background-position: center center;
                            border-radius: 10px;">
                        </div>
                    </div>

                    <div class="col-sm-2" id="<%= "full_name-#{item.id}" %>">
                        <%= live_redirect "#{item.full_name}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.id)
                        %>
                    </div>

                    <div class="col-sm-1" id="<%= "username-#{item.id}" %>">
                        <%= live_redirect "#{item.username}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.id)
                        %>
                    </div>

                    <div class="col" id="<%= "email-#{item.id}" %>">
                        <%= item.email %>
                    </div>

                    <div class="col-sm-1" id="<%= "status-#{item.id}" %>">
                        <%
                            field = Enum.find(MishkaHtmlWeb.AdminUserLive.basic_menu_list, fn x -> x.type == "status" end)
                            {title, _type} = Enum.find(field.options, fn {title, type} -> type == item.status end)
                        %>
                        <%= title %>
                    </div>

                    <div class="col-sm-1" id="<%= "inserted_at-#{item.id}" %>">
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                        %>
                    </div>

                    <div class="col-sm-1" id="<%= "updated-#{item.id}" %>">
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            id: "updated-#{item.id}-component",
                            time: item.updated_at
                        %>
                    </div>

                    <div class="col-sm-3 opration-post-blog" id="<%= "opration-#{item.id}" %>">
                        <a class="btn btn-outline-primary vazir",
                                phx-click="delete"
                                phx-value-id="<%= item.id %>">حذف</a>

                        <%= live_redirect "ویرایش",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserLive, id: item.id),
                            class: "btn btn-outline-danger vazir"
                        %>

                        <%= live_redirect "دسترسی",
                        to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id),
                        class: "btn btn-outline-info vazir"
                        %>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <%= if @users.entries != [] do %>
            <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent ,
                            id: :pagination,
                            pagination_url: @pagination_url,
                            data: @users,
                            filters: @filters,
                            count: @count
            %>
        <% end %>

      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
