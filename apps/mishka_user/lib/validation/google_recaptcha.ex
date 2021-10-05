defmodule MishkaUser.Validation.GoogleRecaptcha do
  alias MishkaDatabase.Cache.SettingCache
  require MishkaTranslator.Gettext

  @url "https://www.google.com/recaptcha/api/siteverify"
  @request_name MyHttpClient

  @spec verify(binary) :: {:error, :verify, String.t()} | {:ok, :verify, map()}
  def verify(token) do
    with {:captcha_status, "production"} <- {:captcha_status, SettingCache.get_config(:public, "captcha_status")},
         {:finch, {:ok, response}} <- {:finch, send_token(token)} do

      response.body |> Jason.decode!() |> error_handler()
    else
      {:finch, {:error, _error}} -> {:error, :verify, "This is a server-side error, if you see it again please contact support"}

      {:captcha_status, developer} ->
        challenge_ts = DateTime.utc_now() |> DateTime.add(1124000, :second) |> DateTime.to_unix()
        {:ok, :verify, %{"action" => "#{developer}", "challenge_ts" => challenge_ts, "hostname" => "localhost", "score" => 10, "success" => true}}
    end
  end

  @spec send_token(String.t) :: {:ok, Finch.Response.t} | {:error, Exception.t}
  def send_token(token) do
    body = %{
      response: token,
      secret: SettingCache.get_config(:public, "google_recaptcha_server_side_code")
    } |> URI.encode_query()

    headers = [
      {"Content-type", "application/x-www-form-urlencoded"},
      {"Accept", "application/json"}
    ]

    Finch.build(:post, @url, headers, body)
    |> Finch.request(@request_name)
  end

  defp error_handler(body) do
    case body do
      %{"action" => _action, "challenge_ts" => _challenge_ts, "hostname" => _hostname, "score" => _score, "success" => true} = verify_info -> {:ok, :verify, verify_info}
      %{"error-codes" => [error_msg], "success" => false} ->  re_captcha_error_messages(error_msg)
    end
  end

  defp re_captcha_error_messages(error) do
    error_msg =
    [
      {"missing-input-secret", MishkaTranslator.Gettext.dgettext("user_captcha", "کد امنیتی ضد رباط شما ارسال نشده است لطفا در صورت نمایش این پیام با پشتیبانی وب سایت در تماس باشید.")},
      {"invalid-input-secret", MishkaTranslator.Gettext.dgettext("user_captcha", "کد امنیتی ضد رباط شما ارسال نشده است لطفا در صورت نمایش این پیام با پشتیبانی وب سایت در تماس باشید.")},
      {"missing-input-response", MishkaTranslator.Gettext.dgettext("user_captcha", "برای ورود باید توکن دریافتی از گوگل را ارسال فرمایید در صورت تلاش مجدد و نمایش دوباره این پیام با پشتیبانی در تماس باشید.")},
      {"invalid-input-response", MishkaTranslator.Gettext.dgettext("user_captcha", "کد ضد رباط شما درست نمی باشد و درخواست شما نا معتبر شناخته شده است لطفا دوباره تلاش کنید")},
      {"bad-request", MishkaTranslator.Gettext.dgettext("user_captcha", "درخواست شما معتبر نمی باشد لطفا دوباره تلاش کنید")},
      {"timeout-or-duplicate", MishkaTranslator.Gettext.dgettext("user_captcha", "درخواست شما قدیمی می باشد لطفا تلاش کنید در صورت تکرار صفحه را رفرش نمایید.")}
    ]
    |> Enum.find(fn {er, _msg} -> er == error end)
    |> case do
      nil -> "Unexpected error"
      {_key, value} -> value
    end

    {:error, :verify, error_msg}
  end

end
