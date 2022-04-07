defmodule MishkaHtmlWeb.Admin.Public.CalendarComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div id="calendarhook" phx-update="ignore">
        <div id="calendar" phx-hook="Calendar"></div>
      </div>
    """
  end
end
