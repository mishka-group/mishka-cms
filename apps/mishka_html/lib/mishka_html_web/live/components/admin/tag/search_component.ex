defmodule MishkaHtmlWeb.Admin.Tag.SearchComponent do
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

              <div class="col-md-3">
                <label for="country" class="form-label">تیتر برچسب</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="title" id="ContentSectionId">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-3">
                <label for="country" class="form-label">تیتر سفارشی برچسب</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="custom_title" id="ContentUserFullName">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-2">
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
