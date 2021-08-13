defmodule MishkaHtmlWeb.Admin.Comment.ListComponent do
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


                <div class="col-sm-2 titile-of-blog-posts alert alert-warning">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@comments, Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col">
                        <span class="badge rounded-pill bg-warning"><%= item.section %></span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-danger"><%= item.status %></span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-dark"><%= MishkaHtml.full_name_sanitize(item.user_full_name) %></span>
                    </div>

                    <div class="col">
                        <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "inserted_at-#{item.id}-component",
                            time: item.inserted_at
                        %>

                    </div>

                    <div class="col-sm-2 opration-post-blog">

                        <%= live_redirect "ویرایش",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminCommentLive, id: item.id),
                            class: "btn btn-outline-danger vazir"
                        %>

                        <a class="btn btn-outline-info vazir",
                                phx-click="dependency"
                                phx-value-id="<%= item.id %>">وابستگی</a>


                        <a class="btn btn-outline-dark vazir",
                                phx-click="delete"
                                phx-value-id="<%= item.id %>">حذف</a>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <div class="space20"></div>
        <%= if @comments.entries != [] do %>
        <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent,
                    id: :pagination,
                    pagination_url: @pagination_url,
                    data: @comments,
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
