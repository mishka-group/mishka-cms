defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "تگرگ",
        body_color: "#40485d",
      )
    {:ok, socket}
  end
end
