defmodule MishkaHtmlWeb.Helpers.TimeConverterComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~H"""
      <span id={@span_id}>
        <% time = jalali_create(@time) %>
        <%= if @detail do %>
          <%= "#{time.day_number} #{time.month_name} سال #{time.year_number} در ساعت #{time.hour}:#{time.minute}:#{time.second}" %>
        <% else %>
          <%= time.day_number %> <%= time.month_name %> <%= time.year_number %>
        <% end %>
      </span>
    """
  end

  def fix_month_and_day(string_number) do
    if String.length("#{string_number}") == 1 do
      "0#{string_number}"
    else
      "#{string_number}"
    end
  end

  def miladi_to_jalaali(datetime) do
    {:ok, jalaali_datetime} = DateTime.convert(datetime, Jalaali.Calendar)
    jalaali_datetime
    |> DateTime.to_string()
    |> String.replace("Z", "")
  end

  def jalali_create(time_need, "number") do
    {:ok, jalaali_date} = DateTime.convert(time_need, Jalaali.Calendar)
    %{day_number: jalaali_date.day, month_name: jalaali_date.month, year_number: jalaali_date.year}
  end

  def jalali_create(time_need) do
    {:ok, jalaali_date} = DateTime.convert(time_need, Jalaali.Calendar)
    %{
      day_number: jalaali_date.day,
      month_name: get_month(jalaali_date.month),
      year_number: jalaali_date.year,
      hour: jalaali_date.hour,
      minute: jalaali_date.minute,
      second: jalaali_date.second
    }
  end

  def get_month(id) do
    case id do
      1 -> "فروردین"
      2 -> "اردیبهشت"
      3 -> "خرداد"
      4 -> "تیر"
      5 -> "مرداد"
      6 -> "شهریور"
      7 -> "مهر"
      8 -> "آبان"
      9 -> "آذر"
      10 -> "دی"
      11 -> "بهمن"
      12 -> "اسفند"
    end
  end
end
