defmodule MishkaHtmlWeb.LoginLive do
  use MishkaHtmlWeb, :live_view

  # alias MishkaUser.User

  def mount(_params, session, socket) do
    user_changeset = %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.login_changeset()

    socket =
      assign(socket,
        page_title: "مدیریت کاربران",
        body_color: "#40485d",
        trigger_submit: false,
        changeset: user_changeset,
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    changeset = user_changeset(params)
    {:noreply,
     assign(
       socket,
       changeset: changeset,
       trigger_submit: changeset.valid?
     )}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset = user_changeset(params)
    {:noreply, assign(socket, changeset: changeset)}
  end


  def user_changeset(params) do
    %MishkaDatabase.Schema.MishkaUser.User{}
    |> MishkaDatabase.Schema.MishkaUser.User.login_changeset(params)
    |> Map.put(:action, :validation)
  end
end
