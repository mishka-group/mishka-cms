defmodule MishkaHtmlWeb.Admin.Blog.CategorySearchComponent do
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

              <div class="col-md-2">
                <label for="country" class="form-label">نحوه نمایش</label>
                <div class="col space10"> </div>
                <select class="form-select" name="category_visibility" id="CategoryVisibility">
                  <option value="">انتخاب</option>
                  <option value="0">نمایش</option>
                  <option value="1">مخفی</option>
                  <option value="2">نمایش تست</option>
                  <option value="3">غیر نمایش تست</option>
                </select>
                <div class="invalid-feedback">
                لطفا گزینه درست را انتخاب کنید.
                </div>
              </div>

              <div class="col-md-3">
                <label for="country" class="form-label">تیتر</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="title">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label">تعداد</label>
                <div class="col space10"> </div>
                <select class="form-select" id="countrecords" name="count">
                  <option value="10">انتخاب</option>
                  <option value="2">20 عدد</option>
                  <option value="30">30 عدد</option>
                  <option value="40">40 عدد</option>
                </select>
                <div class="invalid-feedback">
                لطفا گزینه درست را انتخاب کنید.
                </div>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label">رباط</label>
                <div class="col space10"> </div>
                <select class="form-select" id="ContentRobots" name="robots">
                  <option value="">انتخاب</option>
                  <option value="0">IndexFollow</option>
                  <option value="1">IndexNoFollow</option>
                  <option value="2">NoIndexFollow</option>
                  <option value="3">NoIndexNoFollow</option>
                </select>
                <div class="invalid-feedback">
                  Please select a valid country.
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
end
