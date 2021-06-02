defmodule MishkaHtmlWeb.Admin.Public.CalendarComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
    <div phx-update="ignore">
      <div id="calendar" phx-hook="Calendar"></div>
    </div>
    """
  end
end
