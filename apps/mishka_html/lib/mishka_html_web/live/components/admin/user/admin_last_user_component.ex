defmodule MishkaHtmlWeb.Admin.User.LastUserComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col titile-of-blog-posts alert alert-primary">
                    نام کامل
                </div>

                <div class="col titile-of-blog-posts alert alert-secondary">
                    نام کاربری
                </div>

                <div class="col titile-of-blog-posts alert alert-success">
                    ایمیل
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    ثبت
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-warning">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {_item, color} <- Enum.zip(Enum.shuffle(1..10), Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col">
                        <span class="badge rounded-pill bg-dark">شهریار توکلی</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-info">shahryar</span>
                    </div>

                    <div class="col">
                        shahryar.tbiz@gmail.com
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-primary">فعال</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-secondary">3/7/1400</span>
                    </div>

                    <div class="col-sm-3 opration-post-blog">
                        <button type="button" class="btn btn-outline-info vazir">حذف</button>
                        <button type="button" class="btn btn-outline-warning vazir">حذف کامل</button>

                        <button type="button" class="btn btn-outline-danger vazir">نقش ها</button>
                        <button type="button" class="btn btn-outline-primary vazir">دسترسی ها</button>
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
