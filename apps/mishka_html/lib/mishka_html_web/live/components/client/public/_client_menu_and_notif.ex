
defmodule MishkaHtmlWeb.Client.Public.ClientMenuAndNotif do
  use MishkaHtmlWeb, :live_view
  alias MishkaUser.Token.CurrentPhoenixToken
  alias MishkaContent.General.Notif

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: subscribe(); Notif.subscribe()
    Process.send_after(self(), :update, 10)
    user_id = Map.get(session, "user_id")
    if !is_nil(user_id), do: Process.send_after(self(), {:count_notif, user_id}, 1000)

    socket =
      assign(socket,
        user_id: user_id,
        current_token: Map.get(session, "current_token"),
        notifs: nil,
        menu_name: nil,
        notif_count: 0,
        show_notif: false
      )
    {:ok, socket}
   end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <hr class="menu-space-hr">
        <nav class="navbar navbar-expand-lg">
        <div class="container">

            <div class="row">
                <div class="col navbarNav desc-menu">
                    <ul class="navbar-nav client-menu-navbar-nav">

                        <li class="nav-item client-menu-nav-item">
                            <%=
                                live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "خانه"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
                                class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.HomeLive", @menu_name)}"
                            %>
                        </li>

                        <li class="nav-item client-menu-nav-item">
                            <%=
                                live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "بلاگ"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.BlogsLive),
                                class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.BlogsLive", @menu_name)}"
                            %>
                        </li>

                        <li class="nav-item client-menu-nav-item">
                              <%= if !is_nil(@user_id) do %>
                                  <%= link(MishkaTranslator.Gettext.dgettext("html_live_component", "خروج"), to: "#", class: "nav-link client-menu-nav-link", phx_click: "log_out") %>
                              <% else %>
                                  <%=
                                  live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "ورود"),
                                  to: Routes.live_path(@socket, MishkaHtmlWeb.LoginLive),
                                  class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.LoginLive", @menu_name)}"
                                  %>
                              <% end %>
                        </li>
                    </ul>
                </div>


                <div class="collapse" id="navbarToggleExternalContent">
                <div class="p-4">
                  <div class="col navbarNav">
                    <ul class="navbar-nav client-menu-navbar-nav">

                        <li class="nav-item client-menu-nav-item">
                            <%=
                                live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "خانه"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive),
                                class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.HomeLive", @menu_name)}"
                            %>
                        </li>

                        <li class="nav-item client-menu-nav-item">
                            <%=
                                live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "بلاگ"),
                                to: Routes.live_path(@socket, MishkaHtmlWeb.BlogsLive),
                                class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.BlogsLive", @menu_name)}"
                            %>
                        </li>

                        <li class="nav-item client-menu-nav-item">
                              <%= if !is_nil(@user_id) do %>
                                  <%= link(MishkaTranslator.Gettext.dgettext("html_live_component", "خروج"), to: "#", class: "nav-link client-menu-nav-link", phx_click: "log_out") %>
                              <% else %>
                                  <%=
                                  live_redirect MishkaTranslator.Gettext.dgettext("html_live_component", "ورود"),
                                  to: Routes.live_path(@socket, MishkaHtmlWeb.LoginLive),
                                  class: "nav-link client-menu-nav-link #{change_menu_name("Elixir.MishkaHtmlWeb.LoginLive", @menu_name)}"
                                  %>
                              <% end %>
                        </li>
                    </ul>
                  </div>
                </div>
              </div>

                <nav class="col-sm-3 navbar navbar-dark text-left">
                  <div class="container-fluid mobile-menu">
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarToggleExternalContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
                      <span class="navbar-toggler-icon"></span>
                    </button>
                  </div>
                </nav>



                <%= if !is_nil(@user_id) do %>
                  <div class="col-sm client-notif text-start">
                      <div class="row ltr">
                        <div class="col-sm-3 client-notif-icon" phx-click="show_notif">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-bell" viewBox="0 0 16 16">
                                <path d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zM8 1.918l-.797.161A4.002 4.002 0 0 0 4 6c0 .628-.134 2.197-.459 3.742-.16.767-.376 1.566-.663 2.258h10.244c-.287-.692-.502-1.49-.663-2.258C12.134 8.197 12 6.628 12 6a4.002 4.002 0 0 0-3.203-3.92L8 1.917zM14.22 12c.223.447.481.801.78 1H1c.299-.199.557-.553.78-1C2.68 10.2 3 6.88 3 6c0-2.42 1.72-4.44 4.005-4.901a1 1 0 1 1 1.99 0A5.002 5.002 0 0 1 13 6c0 .88.32 4.2 1.22 6z"/>
                            </svg>
                            <span class="badge bg-primary"><%= @notif_count %></span>
                        </div>

                        <%= if @show_notif and !is_nil(@notifs) and @notifs != [] do %>
                          <div class="col-sm-3 notif-drop vazir rtl">
                            <%= for notif <- @notifs do %>
                              <p phx-click="show_notif_navigate" phx-value-id={notif.id}>
                              <%= if is_nil(notif.user_notif_status.status_type) do %>
                                <span class="d-inline-block bg-danger rounded-circle"></span>
                              <% else %>
                                <span class="d-inline-block bg-secondary rounded-circle"></span>
                              <% end %>
                                <span><%= notif.title %></span>
                                <div class="space10"> </div>
                                <small class="d-block text-muted">
                                  <% des = if MishkaHtml.get_size_of_words(notif.description, 10) != "", do: MishkaHtml.get_size_of_words(notif.description, 10) <> " ... برای ادامه کلیک کنید ..." %>
                                  <%= HtmlSanitizeEx.strip_tags(des) %>
                                </small>
                              </p>
                            <% end %>
                            <div class="space30"> </div>
                            <p class="text-center">
                              <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_templates", "نمایش تمامی اعلانات"), to: Routes.live_path(@socket, MishkaHtmlWeb.NotifsLive), class: "btn btn-outline-secondary btn-lg" %>
                            </p>
                          </div>
                        <% end %>

                      </div>
                  </div>
                <% end %>
            </div>

        </div>
        </nav>
        <hr class="menu-space-hr">
      </div>
    """
  end

  @impl true
  def handle_event("log_out", _params, socket) do
    socket =
      socket
      |> redirect(to: Routes.auth_path(socket, :log_out))

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_notif", _params, socket) do
    # it can be cached after first click, but for new! we do not need it
    socket =
      show_or_close_notif(socket.assigns.notifs, socket.assigns.show_notif, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_notif_navigate", %{"id" => id}, socket) do
    notif =
      Notif.notifs(conditions: {1, 1, :client}, filters: %{id: id, user_id: socket.assigns.user_id, target: :all, type: :client, status: :active})
    {:noreply, MishkaHtmlWeb.NotifsLive.notif_link(socket, notif, socket.assigns.user_id)}
  end

  @impl true
  def handle_info({:menu, name, self_pid}, socket) do
    if socket.parent_pid == self_pid do
     {:noreply, assign(socket, :menu_name, name)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10000)
    socket.assigns.current_token
    |> verify_token()
    |> acl_check(socket)
  end

  @impl true
  def handle_info({:count_notif, user_id}, socket) do
    socket = if(socket.assigns.user_id == user_id, do: assign(socket, notif_count: Notif.count_un_read(socket.assigns.user_id)), else: socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:notif, :ok, repo_record}, socket) do
    socket = if repo_record.user_id == socket.assigns.user_id or is_nil(repo_record.user_id) do
      notifs = MishkaContent.General.Notif.notifs(conditions: {1, 6, :client}, filters: %{
        user_id: socket.assigns.user_id,
        target: :all,
        type: :client,
        status: :active
      })

      socket
      |> assign(notifs: notifs.entries, notif_count: Notif.count_un_read(socket.assigns.user_id))
    else
      socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
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
          |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live_component", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما تغییر کرده باشد لطفا دوباره وارد سایت شوید."))
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.HomeLive))

      end

    {:noreply, socket}
  end

  defp change_menu_name(router_name, menu_name) do
    if(router_name == menu_name, do: "active", else: "")
  end

  defp show_or_close_notif(notif, show_notif, socket) when not is_nil(notif) and show_notif == true do
    socket
    |> assign(show_notif: false)
  end

  defp show_or_close_notif(notif, show_notif, socket) when not is_nil(notif) and show_notif == false do
    socket
    |> assign(show_notif: true)
  end

  defp show_or_close_notif(notif, _show_notif, socket) when is_nil(notif) do
    notifs = MishkaContent.General.Notif.notifs(conditions: {1, 6, :client}, filters: %{
      user_id: socket.assigns.user_id,
      target: :all,
      type: :client,
      status: :active
    })

    socket
    |> assign(notifs: notifs.entries, show_notif: true)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "client_menu_and_notif")
  end

  def notify_subscribers(notif) when is_tuple(notif) do
     Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "client_menu_and_notif", notif)
  end
end
