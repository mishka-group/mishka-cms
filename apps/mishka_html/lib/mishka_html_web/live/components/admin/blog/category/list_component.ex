defmodule MishkaHtmlWeb.Admin.Blog.Category.ListComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col-sm-1 titile-of-blog-posts alert alert-primary">
                    تصویر
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-secondary">
                    تیتر
                </div>

                <div class="col titile-of-blog-posts alert alert-success">
                    نحوه نمایش
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-warning">
                    اولویت
                </div>

                <div class="col titile-of-blog-posts alert alert-success">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    به روز رسانی
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-dark">
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
                            box-shadow: 1px 1px 8px #dadada;background-size: cover;
                            border-radius: 10px;">
                        </div>
                    </div>

                    <div class="col-sm-1" id="<%= "title-#{item.id}" %>">
                        <%= live_redirect "#{item.title}",
                            to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogCategoryLive, id: item.id)
                        %>
                    </div>

                    <div class="col" id="<%= "category-visibility-#{item.id}" %>">
                        <%= item.category_visibility %>
                    </div>

                    <div class="col" id="<%= "status-#{item.id}" %>">
                        <span class="badge bg-primary vazir">
                            <%= item.status %>
                        </span>
                    </div>

                    <div class="col" id="<%= "status-#{item.id}" %>">
                        <span class="badge bg-success">
                        بالا
                        </span>
                    </div>

                    <div class="col" id="<%= "inserted-#{item.id}" %>">
                        <%= item.inserted_at %>
                    </div>

                    <div class="col" id="<%= "updated-#{item.id}" %>">
                        <%= item.updated_at %>
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

        <%= if @categories.entries != [] do %>
            <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent ,
                            id: :pagination,
                            pagination_url: MishkaHtmlWeb.AdminBlogCategoriesLive,
                            data: @categories,
                            filters: @filters,
                            count: @count
            %>
        <% end %>

      </div>
    """
  end
end
