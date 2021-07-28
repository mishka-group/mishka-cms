defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  # TODO: we need to input seo tags
  # TODO: show content
  # TODO: show f posts
  # TODO: paginate

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "تگرگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.HomeLive"})
    {:noreply, socket}
  end
end
