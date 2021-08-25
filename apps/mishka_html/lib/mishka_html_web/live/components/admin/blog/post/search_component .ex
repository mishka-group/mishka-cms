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
      <%= MishkaTranslator.Gettext.dgettext("html_live_component", "جستجوی پیشرفته") %>
      </h2>
      <div class="clearfix"></div>
      <div class="col space30"> </div>
      <div class="col space10"> </div>
      <form  phx-change="search">
        <div class="row vazir admin-list-search-form">
              <div class="col-md-1">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "وضعیت") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="status" id="ContentStatus">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="inactive"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "غیر فعال") %></option>
                  <option value="active"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "فعال") %></option>
                  <option value="archived"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "آرشیو شده") %></option>
                  <option value="soft_delete"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف با پرچم") %></option>
                </select>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اولویت") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="priority" id="PostVisibility">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="none"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بدون اولویت") %></option>
                  <option value="low"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "پایین") %></option>
                  <option value="medium"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "متوسط") %></option>
                  <option value="high"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بالا") %></option>
                  <option value="featured"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ویژه") %></option>
                </select>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نحوه نمایش") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="post_visibility" id="PostVisibility">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="show"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نمایش") %></option>
                  <option value="invisibel"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مخفی") %></option>
                  <option value="test_show"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نمایش تست") %></option>
                  <option value="test_invisibel"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "غیر نمایش تست") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تیتر") %></label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="title" id="title">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مجموعه") %></label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" name="category_title" id="CategoryId">
                <div class="col space10"> </div>
              </div>

              <div class="col-md-1">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "تعداد") %></label>
                <div class="col space10"> </div>
                <select class="form-select" id="countrecords" name="count">
                  <option value="10"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="20"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "%{count} عدد", count: 20) %></option>
                  <option value="30"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "%{count} عدد", count: 30) %></option>
                  <option value="40"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "%{count} عدد", count: 40) %></option>
                </select>
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
              </div>

              <div class="col-sm-2">
                <label for="country" class="form-label vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات سریع") %></label>
                <div class="col space10"> </div>
                <button type="button" class="vazir col-sm-8 btn btn-primary reset-admin-search-btn" phx-click="reset"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ریست") %></button>
              </div>
        </div>
      </form>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
