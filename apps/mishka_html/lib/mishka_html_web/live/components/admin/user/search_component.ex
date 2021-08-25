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
      <%= MishkaTranslator.Gettext.dgettext("html_live_component", "جستجوی پیشرفته") %>
      </h2>
      <div class="clearfix"></div>
      <div class="col space30"> </div>
      <div class="col space10"> </div>
      <form  phx-change="search">
        <div class="row vazir admin-list-search-form">
              <div class="col-sm-1">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "وضعیت") %></label>
                <div class="col space10"> </div>
                <select class="form-select" id="status" name="status">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <option value="registered"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ثبت نام شده") %></option>
                  <option value="active"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "فعال") %></option>
                  <option value="inactive"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "غیر فعال") %></option>
                  <option value="archived"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "آرشیو") %></option>
                </select>
              </div>

              <div class="col-sm-1" id="RoleID">
                <label for="role" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نقش") %></label>
                <div class="col space10"> </div>
                <select class="form-select" id="role-search-id" name="role">
                  <option value=""><%= MishkaTranslator.Gettext.dgettext("html_live_component", "انتخاب") %></option>
                  <%= for role <- MishkaUser.Acl.Role.roles() do %>
                    <option value="<%= role.id %>"><%= role.display_name %></option>
                  <% end %>
                </select>
              </div>

              <div class="col">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام کاربری") %></label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" id="username" name="username">
                <div class="col space10"> </div>
              </div>

              <div class="col">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام کامل") %></label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" id="full_name" name="full_name">
                <div class="col space10"> </div>
              </div>

              <div class="col">
                <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ایمیل") %></label>
                <div class="space10"> </div>
                <input type="text" class="title-input-text form-control" id="email" name="email">
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
