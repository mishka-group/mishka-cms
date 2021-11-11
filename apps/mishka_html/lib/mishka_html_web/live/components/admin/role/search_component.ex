defmodule MishkaHtmlWeb.Admin.Role.SearchComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~H"""
      <div>
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
                <div class="col">
                  <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام نقش") %></label>
                  <div class="space10"> </div>
                  <input type="text" class="title-input-text form-control" name="name" id="Name">
                  <div class="col space10"> </div>
                </div>

                <div class="col">
                  <label for="country" class="form-label"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "نام نمایش نقش") %></label>
                  <div class="space10"> </div>
                  <input type="text" class="title-input-text form-control" name="display_name" id="DisplayName">
                  <div class="col space10"> </div>
                </div>


                <div class="col-sm-2">
                    <label for="country" class="form-label vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "عملیات سریع") %></label>
                    <div class="col space10"> </div>
                    <button type="button" class="vazir col-sm-8 btn btn-primary reset-admin-search-btn" phx-click="reset"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "ریست") %></button>
                </div>
          </div>
        </form>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
