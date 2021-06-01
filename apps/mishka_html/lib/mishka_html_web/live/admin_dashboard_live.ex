defmodule MishkaHtmlWeb.AdminDashboardLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    push_event(socket, "Calendar", %{calendar: %{}})

    {:ok, assign(socket, page_title: "داشبورد مدیریت")}
  end

end
