defmodule MishkaHtmlWeb.Admin.Log.LogSearchComponent do
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

      <div class="row vazir">
            <div class="col">
              <label for="country" class="form-label">نوع</label>
              <div class="col space10"> </div>
              <select class="form-select" id="country" required="">
                <option value="">انتخاب</option>
                <option>فعال</option>
                <option>آرشیو</option>
                <option>حذف با پرچم</option>
              </select>
              <div class="invalid-feedback">
                Please select a valid country.
              </div>
            </div>

            <div class="col">
              <label for="country" class="form-label">پروسه</label>
              <div class="col space10"> </div>
              <select class="form-select" id="country" required="">
                <option value="">انتخاب</option>
                <option>ادمین</option>
                <option>شاپ کیپر</option>
                <option>پشتیبانی</option>
              </select>
              <div class="invalid-feedback">
                Please select a valid country.
              </div>
            </div>

            <div class="col">
              <label for="country" class="form-label">بخش</label>
              <div class="col space10"> </div>
              <select class="form-select" id="country" required="">
                <option value="">انتخاب</option>
                <option>ادمین</option>
                <option>شاپ کیپر</option>
                <option>پشتیبانی</option>
              </select>
              <div class="invalid-feedback">
                Please select a valid country.
              </div>
            </div>

            <div class="col">
              <label for="country" class="form-label">اولویت</label>
              <div class="col space10"> </div>
              <select class="form-select" id="country" required="">
                <option value="">انتخاب</option>
                <option>ادمین</option>
                <option>شاپ کیپر</option>
                <option>پشتیبانی</option>
              </select>
              <div class="invalid-feedback">
                Please select a valid country.
              </div>
            </div>

            <div class="col-sm-3">
              <label for="country" class="form-label">شناسه بخش</label>
              <div class="space10"> </div>
              <input type="text" class="title-input-text form-control">
              <div class="col space10"> </div>
            </div>

            <div class="col-md-1">
              <label for="country" class="form-label">تعداد</label>
              <div class="col space10"> </div>
              <select class="form-select" id="country" required="">
                <option value="">انتخاب</option>
                <option>20 عدد</option>
                <option>30 عدد</option>
                <option>40 عدد</option>
              </select>
              <div class="invalid-feedback">
                Please select a valid country.
              </div>
            </div>

            <div class="col-sm-2">
                <label for="country" class="form-label vazir">عملیات سریع</label>
                <div class="col space10"> </div>
                <button type="button" class="vazir col-sm-8 btn btn-primary reset-admin-search-btn">ریست</button>
            </div>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
