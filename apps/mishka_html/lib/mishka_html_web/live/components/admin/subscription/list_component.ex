defmodule MishkaHtmlWeb.Admin.Subscription.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col titile-of-blog-posts alert alert-primary">
                    بخش
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-success">
                    کاربر
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    انقضا
                </div>

                <div class="col titile-of-blog-posts alert alert-warning">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@subscriptions, Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col">
                        <%
                            field = Enum.find(MishkaHtmlWeb.AdminSubscriptionLive.basic_menu_list, fn x -> x.type == "section" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.section end)
                        %>

                        <span class="badge rounded-pill bg-warning"><%= title %></span>
                    </div>

                    <div class="col">
                    <span class="badge bg-primary vazir">
                        <%
                            field = Enum.find(MishkaHtmlWeb.AdminSubscriptionLive.basic_menu_list, fn x -> x.type == "status" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.status end)
                        %>
                        <%= title %>
                    </span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-dark"><%= item.user_full_name %></span>
                    </div>

                    <div class="col">
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                        %>
                    </div>

                    <div class="col">
                        <%= if is_nil(item.expire_time) do %>
                        <span class="badge rounded-pill bg-secondary"> ندارد </span>
                        <% else %>
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            id: "expire_time-#{item.id}-component",
                            time: item.expire_time
                        %>
                        <% end %>
                    </div>

                    <div class="col opration-post-blog">
                    <%= live_redirect "ویرایش",
                    to: Routes.live_path(@socket, MishkaHtmlWeb.AdminSubscriptionLive, id: item.id),
                    class: "btn btn-outline-info vazir"
                    %>

                    <a class="btn btn-outline-danger vazir",
                                phx-click="delete"
                                phx-value-id="<%= item.id %>">حذف</a>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <div class="space20"></div>
        <%= if @subscriptions.entries != [] do %>
            <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent ,
                            id: :pagination,
                            pagination_url: @pagination_url,
                            data: @subscriptions,
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
