defmodule MishkaHtmlWeb.Admin.User.ActivitiesComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="col-sm-5 vazir list-activity-blog-post-and-category">
        <h3 class="admin-dashbord-h3-right-side-title vazir">آخرین فعالیت ها در مدیریت کاربران</h3>
        <div class="clearfix"></div>
        <div class="space20"></div>
        <div class="clearfix"></div>
        <ul>
            <li>
            <span class="badge bg-dark">۱۲/۸/۱۴۰۰ ساعت ۱۲:</span>
            شهریار توکلی
            یک پست در مجموعه:
            جوملا
            <span class="badge bg-secondary">منتشر</span>
            کرد و منتظر تایید می باشد.
            </li>

            <li>
            <span class="badge bg-dark">۱۲/۸/۱۴۰۰ ساعت ۱۲:</span>
            مطلب
            طراحی سایت در ساختار سازمانی
            به وسیله مدیریت با تمام وابستگی ها
            <span class="badge bg-danger">حذف</span>
            شد.
            </li>

            <li>
            <span class="badge bg-dark">۱۲/۸/۱۴۰۰ ساعت ۱۲:</span>
            مجموعه
            <span class="badge bg-warning text-dark">جوملا</span>
            <span class="badge bg-info text-dark">ویرایش</span>
            شد.
            </li>

            <li>
            <span class="badge bg-dark">۱۲/۸/۱۴۰۰ ساعت ۱۲:</span>
            مجموعه
            <span class="badge bg-warning text-dark">طراحی سایت</span>
            <span class="badge bg-info text-dark">ویرایش</span>
            شد.
            </li>
        </ul>
        <div class="clearfix"></div>
        <div class="space40"></div>
        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
            <button type="button" class="btn btn-outline-danger">برای دیدن اطلاعات بیشتر کلیک کنید</button>
        </div>
    </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
