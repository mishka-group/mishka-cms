defmodule MishkaHtmlWeb.Admin.User.SearchComponent do
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
              <div class="col-sm-1">
                <label for="country" class="form-label">وضعیت</label>
                <div class="col space10"> </div>
                <select class="form-select" id="status" name="status">
                  <option value="">انتخاب</option>
                  <option value="registered">ثبت نام شده</option>
                  <option value="active">فعال</option>
                  <option value="inactive">غیر فعال</option>
                  <option value="archived">آرشیو</option>
                </select>
              </div>

              <div class="col-sm-1" id="RoleID">
                <label for="role" class="form-label">نقش</label>
                <div class="col space10"> </div>
                <select class="form-select" id="role-search-id" name="role">
                  <option value="">انتخاب</option>
                  <%= for role <- MishkaUser.Acl.Role.roles() do %>
                    <option value="<%= role.id %>"><%= role.display_name %></option>
                  <% end %>
                </select>
              </div>

              <div class="col">
                <label for="country" class="form-label">نام کاربری</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" id="username" name="username">
                <div class="col space10"> </div>
              </div>

              <div class="col">
                <label for="country" class="form-label">نام کامل</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" id="full_name" name="full_name">
                <div class="col space10"> </div>
              </div>

              <div class="col">
                <label for="country" class="form-label">ایمیل</label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" id="email" name="email">
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
