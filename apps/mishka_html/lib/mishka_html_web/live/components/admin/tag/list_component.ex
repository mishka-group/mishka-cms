defmodule MishkaHtmlWeb.Admin.Tag.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="table-responsive">
            <table class="table vazir">
                <thead>
                    <tr>
                        <th scope="col" id="div-image">تیتر</th>
                        <th scope="col" id="div-title">تیتر سفارشی</th>
                        <th scope="col" id="div-category">رباط</th>
                        <th scope="col" id="div-status">ثبت</th>
                        <th scope="col" id="div-priority">به روز رسانی</th>
                        <th scope="col" id="div-opration">عملیات</th>
                    </tr>
                </thead>
                <tbody>
                    <%= for {item, color} <- Enum.zip(@tags, Stream.cycle(["wlist", "glist"])) do %>
                    <tr class="blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                        <td class="align-middle text-center">
                            <%= item.title %>
                        </td>
                        <td class="align-middle text-center">
                            <%= if(is_nil(item.custom_title), do: "ندارد", else: item.custom_title) %>
                        </td>
                        <td class="align-middle text-center" id="<%= "title-#{item.id}" %>">
                            <%= item.robots %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                            %>
                        </td>
                        <td class="align-middle text-center">
                            <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "updated-#{item.id}-component",
                            time: item.updated_at
                            %>
                        </td>
                        <td  class="align-middle text-center" id="<%= "opration-#{item.id}" %>">
                            <%= live_redirect "ویرایش",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogTagLive, id: item.id),
                            class: "btn btn-outline-info vazir"
                            %>

                            <a class="btn btn-outline-danger vazir" phx-click="delete" phx-value-id="<%= item.id %>">حذف</a>
                        </td>
                    </tr>
                    <% end %>
                </tbody>
            </table>
            <div class="space20"></div>
            <div class="col-sm-10">
                <%= if @tags.entries != [] do %>
                <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent ,
                                id: :pagination,
                                pagination_url: @pagination_url,
                                data: @tags,
                                filters: @filters,
                                count: @count
                %>
            <% end %>
            </div>
        </div>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
