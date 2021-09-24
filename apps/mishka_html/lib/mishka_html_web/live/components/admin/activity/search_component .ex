defmodule MishkaHtmlWeb.Admin.Activity.SearchComponent do
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
                <select class="form-select" name="status" id="SearchStatus">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="error"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "خطا") %></option>
                  <option value="info"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مشخصات") %></option>
                  <option value="warning"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "هشدار") %></option>
                  <option value="report"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "گزارش شده") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اولویت") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="priority" id="SearchPriority">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="none"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بدون اولویت") %></option>
                  <option value="low"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "پایین") %></option>
                  <option value="medium"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "متوسط") %></option>
                  <option value="high"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بالا") %></option>
                  <option value="featured"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ویژه") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اکشن") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="action" id="SearchAction">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="add"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اضافه کردن") %></option>
                  <option value="edit"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ویرایش کردن") %></option>
                  <option value="delete"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "حذف کردن") %></option>
                  <option value="destroy"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نابود کردن") %></option>
                  <option value="read"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "خواندن") %></option>
                  <option value="send_request"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ارسال شده") %></option>
                  <option value="receive_request"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "دریافت شده") %></option>
                  <option value="other"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "دیگر") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بخش") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="section" id="SearchSection">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="blog_post"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مطلب بلاگ") %></option>
                  <option value="blog_category"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مجموعه بلاگ") %></option>
                  <option value="comment"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نظرات") %></option>
                  <option value="tag"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "برچسب") %></option>
                  <option value="other"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "دیگر") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نوع") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="type" id="SearchType">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="section"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بخش") %></option>
                  <option value="email"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ایمیل") %></option>
                  <option value="internal_api"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "API داخلی") %></option>
                  <option value="external_api"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "API خارجی") %></option>
                </select>
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
