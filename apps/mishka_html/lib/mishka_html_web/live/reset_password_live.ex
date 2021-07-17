defmodule MishkaHtmlWeb.ResetPasswordLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "فراموشی پسورد",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_event("save", %{"email" => email}, socket) do
    # if Capcha code is true
    # if email address exist
    # put flash and reset the ResetPassword form with live redirect
    # send random link to user email
    # the message of put flash should be a public info of user
    # serach how to refresh Capcha
    with {:ok, :get_record_by_field, :user, repo_data} <- MishkaUser.User.show_by_email(email) do
        IO.inspect(repo_data)
      {:noreply, socket}
    else
      {:error, :get_record_by_field, error_tag} ->
        IO.inspect(error_tag)
        {:noreply, socket}
    end
  end

  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.ResetPasswordLive"})
    {:noreply, socket}
  end
end
