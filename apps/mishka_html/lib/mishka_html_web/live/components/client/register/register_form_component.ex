defmodule MishkaHtmlWeb.Client.Register.RegisterFormComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <main class="form-signin vazir">
        <%= f = form_for @changeset, Routes.auth_path(@socket, :login),
            phx_submit: "save",
            phx_change: "validate",
            onkeydown: "return event.key != 'Enter';" %>

          <img class="mb-4" src="<%= Routes.static_path(@socket, "/images/icons8-login-as-user-80.png") %>" alt="" width="80" height="80">
          <div class="space10"></div>
          <h1 class="h3 mb-3 fw-normal">ساخت حساب کاربری جدید</h1>

          <div class="space40"></div>

          <div class="input-group input-group-lg">
              <%= text_input f, :full_name, placeholder: "نام و نام خانوادگی خود را وارد کنید", class: "form-control", autocomplete: "off" %>
          </div>

          <div class="form-error-tag vazir">
            <div class="space10"></div>
            <div class="clearfix"></div>
            <%= error_tag f, :full_name %>
          </div>

          <div class="space20"></div>

          <div class="input-group input-group-lg">
              <%= text_input f, :username, placeholder: "نام کاربری خود را وارد کنید", class: "form-control", autocomplete: "off" %>
          </div>

          <div class="form-error-tag vazir">
            <div class="space10"></div>
            <div class="clearfix"></div>
            <%= error_tag f, :username %>
          </div>


          <div class="space20"></div>



          <div class="input-group input-group-lg">
              <%= email_input f, :email, placeholder: "ایمیل خود را وارد کنید", class: "form-control", autocomplete: "off" %>
          </div>

          <div class="form-error-tag vazir">
            <div class="space10"></div>
            <div class="clearfix"></div>
            <%= error_tag f, :email %>
          </div>


          <div class="space20"></div>

          <div class="input-group input-group-lg">
              <%= password_input f, :password, value: input_value(f, :password), placeholder: "پسورد خود را وارد کنید", class: "form-control", autocomplete: "off" %>
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
            live_redirect "ورود به سایت",
            to: Routes.live_path(@socket, MishkaHtmlWeb.LoginLive),
            class: "btn btn-outline-info"
          %>

          <%=
            live_redirect "فراموشی پسورد",
            to: Routes.live_path(@socket, MishkaHtmlWeb.ResetPasswordLive),
            class: "btn btn-outline-danger"
          %>
        </form>
      </main>
    """
  end

end
