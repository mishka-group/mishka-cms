defmodule MishkaHtmlWeb.LoginLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.User

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      hi
    """
  end
end
