defmodule MishkaHtmlWeb.AuthController do
  use MishkaHtmlWeb, :controller

  def login(conn, _params) do
    render(conn, "login.html")
  end
end
