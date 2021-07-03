defmodule MishkaHtmlWeb.AdminLogLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do

    {:ok, assign(socket, body_color: "#a29ac3cf")}
  end

end
