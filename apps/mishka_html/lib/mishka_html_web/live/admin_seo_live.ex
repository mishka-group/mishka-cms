defmodule MishkaHtmlWeb.AdminSeoLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do

    {:ok, assign(socket, page_title: "تنظیمات سئو", body_color: "#a29ac3cf")}
  end

end
