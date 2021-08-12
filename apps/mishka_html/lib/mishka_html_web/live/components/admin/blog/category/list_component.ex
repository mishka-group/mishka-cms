defmodule MishkaHtmlWeb.Admin.Blog.Category.ListComponent do
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
                    تیتر
                </div>

                <div class="col titile-of-blog-posts alert alert-success" id="div-show">
                    نحوه نمایش
                </div>

                <div class="col titile-of-blog-posts alert alert-danger" id="div-status">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-success" id="div-insert">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-info" id="div-update">
                    به روز رسانی
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-dark" id="div-opreation">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {item, color} <- Enum.zip(@categories, Stream.cycle(["wlist", "glist"])) do %>
                <div phx-update="append" id="<%= item.id %>" class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col-sm-1" id="<%= "image-#{item.id} "%>">
                        <div class="col"
                            style="min-height: 100px;
                            background-image: url(&quot;<%= item.main_image %>&quot;);
                            background-repeat: no-repeat;
                            box-shadow: 1px 1px 8px #dadada;background-size: cover;background-position: center center;
                            border-radius: 10px;">
                        </div>
                    </div>

                    <div class="col-sm-2" id="<%= "title-#{item.id}" %>">
                        <%= live_redirect "#{item.title}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id)
                        %>
                    </div>

                    <div class="col" id="<%= "category-visibility-#{item.id}" %>">
                        <%
                            field = Enum.find(MishkaHtmlWeb.AdminBlogCategoryLive.more_options_menu_list, fn x -> x.type == "category_visibility" end)
                            {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.category_visibility end)
                        %>
                        <%= title %>
                    </div>

                    <div class="col" id="<%= "status-#{item.id}" %>">
                        <span class="badge bg-primary vazir">
                            <%
                                field = Enum.find(MishkaHtmlWeb.AdminBlogCategoryLive.basic_menu_list, fn x -> x.type == "status" end)
                                {title, _type} = Enum.find(field.options, fn {_title, type} -> type == item.status end)
                            %>
                            <%= title %>
                        </span>
                    </div>

                    <div class="col" id="<%= "inserted-#{item.id}" %>">
                        <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "inserted-#{item.id}-component",
                            time: item.inserted_at
                        %>
                    </div>

                    <div class="col" id="<%= "updated-#{item.id}" %>">
                        <%= live_component @socket, MishkaHtmlWeb.Public.TimeConverterComponent,
                            span_id: "updated-#{item.id}-component",
                            time: item.updated_at
                        %>
                    </div>

                    <div class="col-sm-3 opration-post-blog" id="<%= "opration-#{item.id}" %>">
                        <a class="btn btn-outline-primary vazir",
                                phx-click="delete"
                                phx-value-id="<%= item.id %>">حذف</a>

                        <%= live_redirect "ویرایش",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id),
                            class: "btn btn-outline-secondary vazir"
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

        <%= if @categories.entries != [] do %>
            <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent ,
                            id: :pagination,
                            pagination_url: @pagination_url,
                            data: @categories,
                            filters: @filters,
                            count: @count
            %>
        <% end %>

      </div>
    """
  end
end
