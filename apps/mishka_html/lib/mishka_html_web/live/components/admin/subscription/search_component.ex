defmodule MishkaHtmlWeb.Admin.Subscription.SearchComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="clearfix"></div>
      <div class="col space30"> </div>
      <hr>
      <div class="clearfix"></div>
      <div class="col space30"> </div>
      <h2 class="vazir">
      جستجوی پیشرفته
      </h2>
      <div class="clearfix"></div>
      <div class="col space30"> </div>
      <div class="col space10"> </div>

      <form  phx-change="search">
        <div class="row vazir admin-list-search-form">
              <div class="col-md-2">
                <label for="country" class="form-label">وضعیت</label>
                <div class="col space10"> </div>
                <select class="form-select" name="status" id="ContentStatus">
                  <option value="">انتخاب</option>
                  <option value="inactive">غیر فعال</option>
                  <option value="active">فعال</option>
                  <option value="archived">آرشیو شده</option>
                  <option value="soft_delete">حذف با پرچم</option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label">بخش</label>
                <div class="col space10"> </div>
                <select class="form-select" name="section" id="ContentSection">
                  <option value="blog_post">مطالب</option>
                </select>
              </div>

              <div class="col-md-3">
                <label for="country" class="form-label">شناسه بخش</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="section_id" id="ContentSectionId">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label">نام کاربر</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="full_name" id="ContentUserFullName">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label">تعداد</label>
                <div class="col space10"> </div>
                <select class="form-select" id="countrecords" name="count">
                  <option value="10">انتخاب</option>
                  <option value="20">20 عدد</option>
                  <option value="30">30 عدد</option>
                  <option value="40">40 عدد</option>
                </select>

              </div>

              <div class="col-sm-2">
                  <label for="country" class="form-label vazir">عملیات سریع</label>
                  <div class="col space10"> </div>
                  <button type="button" class="vazir col-sm-8 btn btn-primary reset-admin-search-btn" phx-click="reset">ریست</button>
              </div>
        </div>
      </form>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
