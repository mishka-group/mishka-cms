defmodule MishkaHtmlWeb.Admin.Log.LastLogComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col titile-of-blog-posts alert alert-primary">
                    نوع
                </div>

                <div class="col titile-of-blog-posts alert alert-secondary">
                    بخش
                </div>

                <div class="col-sm-3 titile-of-blog-posts alert alert-success">
                    شناسه بخش
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    اولویت
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    وضعیت
                </div>

                <div class="col titile-of-blog-posts alert alert-primary">
                    پروسه
                </div>

                <div class="col titile-of-blog-posts alert alert-secondary">
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
                        <span class="badge rounded-pill bg-dark">ارسال ایمیل</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-info">محتوا</span>
                    </div>

                    <div class="col-sm-3">
                        <span class="badge rounded-pill bg-danger">0b0c31e8-cbd1-4585-ac10-40db212ef97d</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-primary">بالا</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-secondary">خطا</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-warning">ساخت</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-primary">3/7/1400</span>
                    </div>

                    <div class="col-sm-3 opration-post-blog">
                        <button type="button" class="btn btn-outline-primary vazir">حذف</button>
                        <button type="button" class="btn btn-outline-warning vazir">حذف کامل</button>

                        <button type="button" class="btn btn-outline-danger vazir">نقش ها</button>
                        <button type="button" class="btn btn-outline-info vazir">دسترسی ها</button>
                    </div>
                </div>
                <div class="space20"></div>
                <div class="clearfix"></div>
            <% end %>
        </div>

        <div class="space20"></div>
        <%= live_component @socket, MishkaHtmlWeb.Public.PaginationComponent , id: :pagination %>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
