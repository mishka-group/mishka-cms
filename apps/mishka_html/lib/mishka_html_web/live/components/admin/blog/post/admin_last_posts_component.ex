defmodule MishkaHtmlWeb.Admin.Blog.LastPostsComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col-sm-1 titile-of-blog-posts alert alert-dark">
                    تصویر
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    تیتر
                </div>

                <div class="col-sm-1 titile-of-blog-posts alert alert-warning">
                    مجموعه
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-success">
                    اولویت
                </div>

                <div class="col titile-of-blog-posts alert alert-secondary">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-primary">
                    به روز رسانی
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    انقضا
                </div>

                <div class="col-sm-2 titile-of-blog-posts alert alert-info">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {_item, color} <- Enum.zip(Enum.shuffle(1..10), Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col-sm-1">
                        <div class="col"
                            style="min-height: 100px;
                            background-image: url(&quot;../images/test2.jpg&quot;);
                            background-repeat: no-repeat;
                            box-shadow: 1px 1px 8px #dadada;background-size: cover;
                            border-radius: 10px;">
                        </div>
                    </div>

                    <div class="col">
                        <a href="#">
                        طراحی سایت با محتوای بهینه و تنظیم سئو
                        </a>
                    </div>

                    <div class="col-sm-1">
                        <a href="#">
                        جوملا
                        </a>
                    </div>

                    <div class="col">
                        <span class="badge bg-primary vazir">
                            فعال
                        </span>
                    </div>

                    <div class="col">
                        <span class="badge bg-success">
                        بالا
                        </span>
                    </div>

                    <div class="col">
                    3/7/1400
                    </div>

                    <div class="col">
                    13/7/1400
                    </div>

                    <div class="col">
                        13/7/1400
                    </div>

                    <div class="col-sm-2 opration-post-blog">
                        <button type="button" class="btn btn-outline-primary vazir">حذف</button>
                        <button type="button" class="btn btn-outline-secondary vazir">ویرایش</button>
                        <div class="clearfix"></div>
                        <div class="space10"></div>
                        <button type="button" class="btn btn-outline-success vazir">نظرات</button>
                        <button type="button" class="btn btn-outline-danger vazir">حذف کامل </button>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <div class="space20"></div>

        <%= live_component @socket, MishkaHtmlWeb.Admin.PaginationComponent , id: :pagination %>

      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
