defmodule MishkaHtmlWeb.AdminMediaManagerLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do

    {:ok, assign(socket, page_title: "مدیریت فایل ها")}
  end

end
