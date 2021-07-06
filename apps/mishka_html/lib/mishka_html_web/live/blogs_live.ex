defmodule MishkaHtmlWeb.BlogsLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      assign(socket,
        page_title: "بلاگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end
end
