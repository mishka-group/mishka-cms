defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 1000)
    ### create a simple GenServer or Mnesia to store user id key, token, last_use
    ### update last use every mount
    ### redirect user to login page
    ### discounect endpoint
    ### clear token and all session
    ### if user verify change login menu to logout
    ### force logiend user not to see register and reset password
    ### create a plug to check user login token and ACL
    ### add acl to another stroge to accsess fast not db
    # create task to delete session after 24 hours if not to be used
    # create a handel info def to see user changed like (role and ACL etc, change password)
    socket =
      assign(socket,
        page_title: "تگرگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_info(:menu, socket) do
    MishkaHtmlWeb.Client.Public.ClientMenuAndNotif.notify_subscribers({:menu, "home"})
    {:noreply, socket}
  end
end
