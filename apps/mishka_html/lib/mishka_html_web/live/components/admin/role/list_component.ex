defmodule MishkaHtmlWeb.Admin.Role.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col titile-of-blog-posts alert alert-primary">
                    نام
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    نام نمایش
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-warning">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@roles, Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col">

                        <span class="badge bg-info"><%= item.name %></span>
                    </div>

                    <div class="col">
                    <span class="badge bg-primary vazir">
                        <%= item.display_name %>
                    </span>
                    </div>

                    <div class="col">
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            span_id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                        %>
                    </div>


                    <div class="col opration-post-blog">
                    <%= live_redirect "مدیریت دسترسی ها",
                    to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUserRolePermissionsLive, id: item.id),
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
        <%= if @roles.entries != [] do %>
            <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent ,
                            id: :pagination,
                            pagination_url: @pagination_url,
                            data: @roles,
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
