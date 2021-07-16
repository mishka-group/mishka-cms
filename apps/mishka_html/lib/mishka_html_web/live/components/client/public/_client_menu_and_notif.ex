
defmodule MishkaHtmlWeb.Client.Public.ClientMenuAndNotif do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Token.CurrentPhoenixToken
  def mount(_params, session, socket) do
    if connected?(socket), do: subscribe()
    Process.send_after(self(), :update, 10)
    socket =
      assign(socket,
        user_id: Map.get(session, "user_id"),
        current_token: Map.get(session, "current_token"),
        # notifs should be edited and read field is added, true or false.
        # notif read false count and paginate
        notifs: nil,
        menu_name: nil
      )
    {:ok, socket}
   end

  def render(assigns) do
    ~L"""
      <hr class="menu-space-hr">
      <nav class="navbar navbar-expand-lg">
      <div class="container">

          <div class="row">
              <div class="col navbarNav">
                  <ul class="navbar-nav client-menu-navbar-nav">

                      <li class="nav-item client-menu-nav-item">
                          <%=
                              live_redirect "خانه",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
                              class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.HomeLive", @menu_name)}"
                          %>
                      </li>

                      <li class="nav-item client-menu-nav-item">
                          <%=
                              live_redirect "بلاگ",
                              to: Routes.live_path(@socket, MishkaHtmlWeb.BlogsLive),
                              class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.BlogsLive", @menu_name)}"
                          %>
                      </li>

                      <li class="nav-item client-menu-nav-item">
                            <%= if !is_nil(@user_id) do %>
                                <%= link("خروج", to: Routes.auth_path(@socket, :log_out), class: "nav-link client-menu-nav-link") %>
                            <% else %>
                                <%=
                                live_redirect "ورود",
                                to: Routes.live_path(@socket, MishkaHtmlWeb.LoginLive),
                                class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.LoginLive", @menu_name)}"
                                %>
                            <% end %>
                      </li>
                  </ul>
              </div>

              <%= if !is_nil(@notifs) do %>
                <div class="col-sm-3 client-notif">
                    <div class="row ltr">
                        <div class="col-sm-3 client-notif-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-bell" viewBox="0 0 16 16">
                                <path d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zM8 1.918l-.797.161A4.002 4.002 0 0 0 4 6c0 .628-.134 2.197-.459 3.742-.16.767-.376 1.566-.663 2.258h10.244c-.287-.692-.502-1.49-.663-2.258C12.134 8.197 12 6.628 12 6a4.002 4.002 0 0 0-3.203-3.92L8 1.917zM14.22 12c.223.447.481.801.78 1H1c.299-.199.557-.553.78-1C2.68 10.2 3 6.88 3 6c0-2.42 1.72-4.44 4.005-4.901a1 1 0 1 1 1.99 0A5.002 5.002 0 0 1 13 6c0 .88.32 4.2 1.22 6z"/>
                            </svg>
                            <span class="badge bg-primary"><%= @notifs %></span>
                        </div>
                    </div>
                </div>
              <% end %>

          </div>

      </div>
      </nav>
      <hr class="menu-space-hr">
    """
  end

  def handle_info({:menu, name}, socket) do
     {:noreply, assign(socket, :menu_name, name)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10000)
    socket.assigns.current_token
    |> verify_token()
    |> acl_check(socket)
  end

  defp verify_token(nil), do: {:error, :verify_token, :no_token}

  defp verify_token(current_token) do
    case CurrentPhoenixToken.verify_token(current_token, :current) do
      {:ok, :verify_token, :current, current_token_info} -> {:ok, :verify_token, current_token_info["id"], current_token}

      _ -> {:error, :verify_token}
    end
  end

  defp acl_check({:error, :verify_token, :no_token}, socket), do: {:noreply, socket}

  defp acl_check({:error, :verify_token}, socket) do
    socket =
      socket
      |> redirect(to: Routes.auth_path(socket, :log_out))

    {:noreply, socket}
  end

  defp acl_check({:ok, :verify_token, user_id, current_token}, socket) do
    acl_got = Map.get(MishkaUser.Acl.Action.actions, socket.assigns.menu_name)

    socket =
      with {:acl_check, false, action} <- {:acl_check, is_nil(acl_got), acl_got},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          socket
          |> assign(user_id: user_id, current_token: current_token)

      else
        {:acl_check, true, nil} ->

          socket
          |> assign(user_id: user_id, current_token: current_token)

        {:permittes?, false} ->

          socket
          |> put_flash(:warning, "شما به این صفحه دسترسی ندارید.")
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.HomeLive))

      end

    {:noreply, socket}
  end

  defp change_menu_name(router_name, menu_name) do
    if(router_name == menu_name, do: "active", else: "")
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "client_menu_and_notif")
  end

  def notify_subscribers(notif) when is_tuple(notif) do
     Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "client_menu_and_notif", notif)
  end
end
