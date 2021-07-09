defmodule MishkaHtmlWeb.AdminUserRolesLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    # socket =
    #   assign(socket,
    #     dynamic_form: [],
    #     page_title: "ساخت یا ویرایش کاربر",
    #     body_color: "#a29ac3cf",
    #     basic_menu: false,
    #     id: nil,
    #     changeset: user_changeset())
    {:ok, socket}
  end
end
