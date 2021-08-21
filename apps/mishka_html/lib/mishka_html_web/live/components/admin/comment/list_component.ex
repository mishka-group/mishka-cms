defmodule MishkaHtmlWeb.Admin.Comment.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">


      <div class="table-responsive">
            <table class="table vazir">
                    <thead>
                        <tr>
                            <th scope="col" id="div-title">بخش</th>
                            <th scope="col" id="div-category">وضعیت</th>
                            <th scope="col" id="div-status">کاربر</th>
                            <th scope="col" id="div-priority">ثبت</th>
                            <th scope="col" id="div-opration">عملیات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= for {item, color} <- Enum.zip(@comments, Stream.cycle(["wlist", "glist"])) do %>
                        <tr class="blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                            <td class="align-middle text-center">
                                <%= item.section %>
                            </td>
                            <td class="align-middle text-center" id="<%= "title-#{item.id}" %>">
                                <span class="badge rounded-pill bg-danger"><%= item.status %></span>
                            </td>
                            <td class="align-middle text-center">
                                <%= MishkaHtml.full_name_sanitize(item.user_full_name) %>
                            </td>

                            <td class="align-middle text-center">
                                <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                                span_id: "inserted_at-#{item.id}-component",
                                time: item.inserted_at
                                %>
                            </td>
                            <td  class="align-middle text-center" id="<%= "opration-#{item.id}" %>">
                                <%= live_redirect "ویرایش",
                                to: Routes.live_path(@socket, MishkaHtmlWeb.AdminCommentLive, id: item.id),
                                class: "btn btn-outline-danger vazir"
                                %>

                                <a class="btn btn-outline-info vazir", phx-click="dependency" phx-value-id="<%= item.id %>">وابستگی</a>
                                <a class="btn btn-outline-dark vazir", phx-click="delete" phx-value-id="<%= item.id %>">حذف</a>

                            </td>
                        </tr>
                        <% end %>
                    </tbody>
                </table>
                <div class="space20"></div>
                <div class="col-sm-10">
                    <%= if @comments.entries != [] do %>
                    <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent ,
                                    id: :pagination,
                                    pagination_url: @pagination_url,
                                    data: @comments,
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
