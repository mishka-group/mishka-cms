defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    ### create a simple GenServer or Mnesia to store user id key, token, last_use, acl
    ### update last use every mount
    # breack last use if not to use more than 25 minists
    # redirect user to login page
    # discounect endpoint
    # clear token and all session
    # create task to delete session after 24 hours if not to be used for 25 minists
    # if user verify change login menu to logout
    # force logiend user no to see register and reset password
    # create a plug to check user login token and ACL
    # create a handel info def to see user changed like (role and ACL etc, change password)

    # IO.inspect MishkaUser.Token.CurrentPhoenixToken.verify_token(current_token, :current)

    socket =
      assign(socket,
        page_title: "تگرگ",
        body_color: "#40485d",
      )
    {:ok, socket}
  end
end
