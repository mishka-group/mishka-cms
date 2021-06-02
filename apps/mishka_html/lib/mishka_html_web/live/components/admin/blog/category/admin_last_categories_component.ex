defmodule MishkaHtmlWeb.Admin.Blog.LastCategoriesComponent do
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
                <div id="<%= item.category_id %>" class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col-sm-1">
                        <div class="col"
                            style="min-height: 100px;
                            background-image: url(&quot;../images/test2.jpg&quot;);
                            background-repeat: no-repeat;
                            box-shadow: 1px 1px 8px #dadada;background-size: cover;
                            border-radius: 10px;">
                        </div>
                    </div>

                    <div class="col-sm-1">
                        <a href="#">
                        <%= item.category_title %>
                        </a>
                    </div>

                    <div class="col">
                        <%= item.category_visibility %>
                    </div>

                    <div class="col">
                        <span class="badge bg-primary vazir">
                            <%= item.category_status %>
                        </span>
                    </div>

                    <div class="col">
                        <span class="badge bg-success">
                        بالا
                        </span>
                    </div>

                    <div class="col">
                        <%= item.category_inserted_at %>
                    </div>

                    <div class="col">
                        <%= item.category_updated_at %>
                    </div>

                    <div class="col-sm-3 opration-post-blog">
                        <button type="button" class="btn btn-outline-primary vazir">حذف</button>
                        <button type="button" class="btn btn-outline-secondary vazir">ویرایش</button>
                        <button type="button" class="btn btn-outline-success vazir">نظرات</button>
                        <button type="button" class="btn btn-outline-danger vazir">حذف کامل </button>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent ,
                            id: :pagination,
                            pagination_url: MishkaHtmlWeb.AdminBlogCategoriesLive,
                            data: @categories
        %>
      </div>
    """
  end
end
