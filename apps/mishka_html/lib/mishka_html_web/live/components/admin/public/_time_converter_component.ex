defmodule MishkaHtmlWeb.Admin.Public.TimeConverterComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <span id="#{id}">
      <% time_need = jalali_create(@time) %>
      <%= time_need.day_number %> <%= time_need.month_name %> <%= time_need.year_number %>
      </span>
    """
  end

  def jalali_string_to_miladi_english_number(persian_datetime) do
    [yy, mm, dd] = String.split(persian_datetime, "/")
    {:ok, jalaali_date} = Date.new(Numero.normalize_as_number!(yy), Numero.normalize_as_number!(mm), Numero.normalize_as_number!(dd), Jalaali.Calendar)
    {:ok, iso_date} = Date.convert(jalaali_date, Calendar.ISO)
    {:ok, datetime, 0} = DateTime.from_iso8601("#{iso_date.year}-#{fix_month_and_day(iso_date.month)}-#{fix_month_and_day(iso_date.day)}T00:00:00Z")
    datetime
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
    {:ok, jalaali_date} = Date.convert(time_need, Jalaali.Calendar)
    %{day_number: jalaali_date.day, month_name: jalaali_date.month, year_number: jalaali_date.year}
  end

  def jalali_create(time_need) do
    {:ok, jalaali_date} = Date.convert(time_need, Jalaali.Calendar)
    %{day_number: jalaali_date.day, month_name: get_month(jalaali_date.month), year_number: jalaali_date.year}
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
