defmodule MishkaHtmlWeb.Admin.Subscription.LastSubscriptionComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col bw admin-blog-post-list">
        <div class="row vazir">
            <div class="row vazir">
                <div class="col titile-of-blog-posts alert alert-primary">
                    بخش
                </div>

                <div class="col-sm-4 titile-of-blog-posts alert alert-secondary">
                    شناسه بخش
                </div>

                <div class="col titile-of-blog-posts alert alert-success">
                    کاربر
                </div>

                <div class="col titile-of-blog-posts alert alert-info">
                    ثبت
                </div>

                <div class="col titile-of-blog-posts alert alert-danger">
                    انقضا
                </div>

                <div class="col titile-of-blog-posts alert alert-warning">
                    عملیات
                </div>
            </div>

            <div class="clearfix"></div>
            <div class="space40"></div>
            <div class="clearfix"></div>

            <%= for {_item, color} <- Enum.zip(Enum.shuffle(1..10), Stream.cycle(["wlist", "glist"])) do %>
                <div class="row blog-list vazir <%= if color == "glist", do: "odd-list-of-blog-posts" %>">
                    <div class="col">
                        <span class="badge rounded-pill bg-warning">بلاگ</span>
                    </div>

                    <div class="col-sm-4">

                        <span class="badge rounded-pill bg-info"><%= Ecto.UUID.generate %></span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-dark">شهریار توکلی</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-primary">3/7/1400</span>
                    </div>

                    <div class="col">
                        <span class="badge rounded-pill bg-secondary">3/7/1400</span>
                    </div>

                    <div class="col opration-post-blog">
                        <button type="button" class="btn btn-outline-danger vazir">حذف</button>
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
