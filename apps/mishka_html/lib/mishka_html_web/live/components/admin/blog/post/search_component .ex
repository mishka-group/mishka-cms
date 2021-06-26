defmodule MishkaHtmlWeb.Admin.Blog.Post.SearchComponent do
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
        <div class="row vazir">
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
                <div class="invalid-feedback">
                  لطفا گزینه درست را انتخاب کنید.
                </div>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label">اولویت</label>
                <div class="col space10"> </div>
                <select class="form-select" name="priority" id="PostVisibility">
                  <option value="">انتخاب</option>
                  <option value="none">بدون اولویت</option>
                  <option value="show">نمایش</option>
                  <option value="invisibel">مخفی</option>
                  <option value="test_show">نمایش تست</option>
                  <option value="test_invisibel">غیر نمایش تست</option>
                </select>
                <div class="invalid-feedback">
                  Please select a valid country.
                </div>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label">تیتر</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="title" id="title">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label">مجموعه</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="category_id" id="CategoryId">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label">تعداد</label>
                <div class="col space10"> </div>
                <select class="form-select" id="countrecords" name="count">
                  <option value="">انتخاب</option>
                  <option>20 عدد</option>
                  <option>30 عدد</option>
                  <option>40 عدد</option>
                </select>
                <div class="invalid-feedback">
                  Please select a valid country.
                </div>
              </div>


              <div class="col-md-2">
                <label for="country" class="form-label">رباط</label>
                <div class="col space10"> </div>
                <select class="form-select" id="ContentRobots" name="robots">
                  <option value="">انتخاب</option>
                  <option value="IndexFollow">IndexFollow</option>
                  <option value="IndexNoFollow">IndexNoFollow</option>
                  <option value="NoIndexFollow">NoIndexFollow</option>
                  <option value="NoIndexNoFollow">NoIndexNoFollow</option>
                </select>
                <div class="invalid-feedback">
                  لطفا گزینه درست را انتخاب کنید.
                </div>
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
