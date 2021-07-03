defmodule MishkaHtmlWeb.Client.Public.MenuComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <hr class="menu-space-hr">
      <nav class="navbar navbar-expand-lg">
      <div class="container">

          <div class="row">
              <div class="col navbarNav">
                  <ul class="navbar-nav">

                      <li class="nav-item">
                          <%=
                              live_redirect "خانه",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
                              class: "nav-link active"
                          %>
                      </li>

                      <li class="nav-item">
                          <%=
                              live_redirect "بلاگ",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.BlogsLive),
                              class: "nav-link"
                          %>
                      </li>

                      <li class="nav-item">
                          <%=
                              live_redirect "پادکست",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
                              class: "nav-link"
                          %>
                      </li>

                      <li class="nav-item">
                          <%=
                              live_redirect "گالری",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.LoginLive),
                              class: "nav-link"
                          %>
                      </li>

                      <li class="nav-item">
                          <%=
                              live_redirect "ورود",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.LoginLive),
                              class: "nav-link"
                          %>
                      </li>
                  </ul>
              </div>

              <div class="col-sm-3 client-notif">
                  <div class="row ltr">

                      <div class="col-sm-3 client-notif-icon">
                          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-bell" viewBox="0 0 16 16">
                              <path d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zM8 1.918l-.797.161A4.002 4.002 0 0 0 4 6c0 .628-.134 2.197-.459 3.742-.16.767-.376 1.566-.663 2.258h10.244c-.287-.692-.502-1.49-.663-2.258C12.134 8.197 12 6.628 12 6a4.002 4.002 0 0 0-3.203-3.92L8 1.917zM14.22 12c.223.447.481.801.78 1H1c.299-.199.557-.553.78-1C2.68 10.2 3 6.88 3 6c0-2.42 1.72-4.44 4.005-4.901a1 1 0 1 1 1.99 0A5.002 5.002 0 0 1 13 6c0 .88.32 4.2 1.22 6z"/>
                              <span class="badge bg-primary"><%= @notifs %></span>
                          </svg>
                      </div>
                  </div>
              </div>

          </div>

      </div>
      </nav>
      <hr class="menu-space-hr">
    """
  end

end
