defmodule MishkaHtmlWeb.AdminUserLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do

    {:ok, assign(socket, changeset: "changeset")}
  end

end
