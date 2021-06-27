defmodule MishkaHtmlWeb.Admin.Blog.Post.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col-sm-1 titile-of-blog-posts alert alert-dark" id="div-image">
                    تصویر
                </div>

                <div class="col titile-of-blog-posts alert alert-info" id="div-title">
                    تیتر
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-warning" id="div-category">
                    مجموعه
                </div>

                <div class="col titile-of-blog-posts alert alert-danger" id="div-status">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-success" id="div-priority">
                    اولویت
                </div>

                <div class="col titile-of-blog-posts alert alert-secondary" id="div-insert">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-primary" id="div-update">
                    به روز رسانی
                </div>

                <div class="col titile-of-blog-posts alert alert-danger" id="div-exp">
                    انقضا
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-info" id="div-opration">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@posts, Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col-sm-1">
                        <div class="col"
                            style="min-height: 100px;
                            background-image: url(&quot;<%= item.main_image %>&quot;);
                            background-repeat: no-repeat;
                            box-shadow: 1px 1px 8px #dadada;background-size: cover;background-position: center center;
                            border-radius: 10px;">
                        </div>
                    </div>

                    <div class="col" id="<%= "title-#{item.id}" %>">
                        <%= live_redirect "#{item.title}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogPostLive, id: item.id)
                        %>
                    </div>

                    <div class="col-sm-1">
                        <%= live_redirect "#{item.category_title}",
                        to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.category_id)
                        %>
                    </div>

                    <div class="col">
                        <%
                        field = Enum.find(MishkaHtmlWeb.AdminBlogPostLive.basic_menu_list, fn x -> x.type == "status" end)
                        {title, _type} = Enum.find(field.options, fn {title, type} -> type == item.status end)
                        %>
                        <span class="badge bg-info"><%= title %></span>
                    </div>

                    <div class="col">

                        <%
                        field = Enum.find(MishkaHtmlWeb.AdminBlogPostLive.basic_menu_list, fn x -> x.type == "priority" end)
                        {title, _type} = Enum.find(field.options, fn {title, type} -> type == item.priority end)
                        %>
                        <span class="badge bg-success"><%= title %></span>
                    </div>

                    <div class="col">
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                        id: "inserted-#{item.id}-component",
                        time: item.inserted_at
                        %>
                    </div>

                    <div class="col">
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                        id: "updated_at-#{item.id}-component",
                        time: item.updated_at
                        %>
                    </div>

                    <div class="col">
                        <%= if is_nil(item.unpublish) do %>
                            ندارد
                        <% else %>
                        <%= live_component @socket, MishkaHtmlWeb.Admin.Public.TimeConverterComponent,
                            id: "unpublish-#{item.id}-component",
                            time: item.unpublish
                        %>
                        <% end %>
                    </div>

                    <div class="col-sm-3 opration-post-blog" id="<%= "opration-#{item.id}" %>">
                        <a class="btn btn-outline-primary vazir",
                                    phx-click="delete"
                                    phx-value-id="<%= item.id %>">حذف</a>

                        <%= live_redirect "ویرایش",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id),
                            class: "btn btn-outline-secondary vazir"
                        %>

                        <%= live_redirect "نظرات",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id),
                            class: "btn btn-outline-success vazir"
                        %>

                        <%= live_redirect "حذف کامل",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id),
                            class: "btn btn-outline-danger vazir"
                        %>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <div class="space20"></div>

        <%= if @posts.entries != [] do %>
        <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent ,
                        id: :pagination,
                        pagination_url: @pagination_url,
                        data: @posts,
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
