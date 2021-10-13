defmodule MishkaHtmlWeb.Admin.Notif.SearchComponent do
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
              <div class="col-md-2">
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

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "بخش") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="section" id="Section">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="blog_post"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مطلب") %></option>
                  <option value="admin"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مدیریت") %></option>
                  <option value="user_only"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مختص به کاربر") %></option>
                  <option value="public"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عمومی/انبوه") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نوع") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="type" id="Type">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="client"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "کاربری") %></option>
                  <option value="admin"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مدیریتی") %></option>
                </select>
              </div>

              <div class="col-md-2">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "هدف") %></label>
                <div class="col space10"> </div>
                <select class="form-select" name="target" id="Target">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="all"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "همه") %></option>
                  <option value="mobile"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "موبایل") %></option>
                  <option value="android"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اندروید") %></option>
                  <option value="ios"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ios") %></option>
                  <option value="cli"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "cli") %></option>
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
end
