defmodule MishkaHtmlWeb.Admin.Public.CalendarComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div id="calendar" phx-hook="Calendar"> </div>
    """
  end
end
