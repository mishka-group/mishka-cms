defmodule MishkaHtmlWeb.Client.Login.LoginFormComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <main class="form-signin vazir">
        <%= f = form_for @changeset, Routes.auth_path(@socket, :login),
            phx_submit: "save",
            phx_change: "validate",
            phx_trigger_action: @trigger_submit %>

          <img class="mb-4" src="<%= Routes.static_path(@socket, "/images/icons8-login-as-user-80.png") %>" alt="" width="80" height="80">
          <div class="space10"></div>
          <h1 class="h3 mb-3 fw-normal">لطفا وارد شوید</h1>

          <div class="space40"></div>

          <div class="input-group input-group-lg ltr">
              <%= email_input f, :email, placeholder: "Email", class: "form-control" %>
          </div>

          <div class="form-error-tag vazir">
            <div class="space10"></div>
            <div class="clearfix"></div>
            <%= error_tag f, :email %>
          </div>

          <div class="space20"></div>

          <div class="input-group input-group-lg ltr">
              <%= password_input f, :password, value: input_value(f, :password), placeholder: "Password", class: "form-control", autocomplete: "off" %>
          </div>
          <div class="form-error-tag vazir">
          <div class="space20"></div>
          <div class="clearfix"></div>
            <%= error_tag f, :password %>
          </div>

          <div class="space20"></div>

          <%= submit "ورود به سایت", phx_disable_with: "Login..." , class: "w-100 btn btn-lg btn-primary", disabled: !@changeset.valid? %>

          <div class="space20"></div>
          <%=
            live_redirect "ثبت نام در سایت",
            to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
            class: "btn btn-outline-info"
          %>

          <%=
            live_redirect "فراموشی پسورد",
            to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
            class: "btn btn-outline-danger"
          %>
        </form>
      </main>
    """
  end

end
