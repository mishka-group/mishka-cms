defmodule MishkaUser.Validation.GoogleRecaptcha do
  # TODO: next version should have remoteip checker
  # TODO: these config should be stored on state and db

  @url "https://www.google.com/recaptcha/api/siteverify"
  @request_name MyHttpClient
  @secret System.get_env("CAPTCHA_SERVER_SIDE_CODE")
  @captcha_status :production

  @spec verify(binary) :: {:error, :verify, String.t()} | {:ok, :verify, map()}
  def verify(token) do
    with {:finch, {:ok, response}} <- {:finch, send_token(token)},
         {:captcha_status, :production} <- {:captcha_status, @captcha_status} do

      response.body |> Jason.decode!() |> error_handler()
    else
      {:finch, {:error, _error}} -> {:error, :verify, "This is a server-side error, if you see it again please contact support"} # TODO: should save on log activity

      {:captcha_status, developer} ->
        challenge_ts = DateTime.utc_now() |> DateTime.add(1124000, :second) |> DateTime.to_unix()
        {:ok, :verify, %{"action" => "#{developer}", "challenge_ts" => challenge_ts, "hostname" => "localhost", "score" => 10, "success" => true}}
    end
  end

  @spec send_token(String.t) :: {:ok, Finch.Response.t} | {:error, Exception.t}
  def send_token(token) do
    body = %{
      response: token,
      secret: @secret
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
      {"missing-input-secret", "The secret parameter is missing."},
      {"invalid-input-secret", "The secret parameter is invalid or malformed."},
      {"missing-input-response", "The response parameter is missing."},
      {"invalid-input-response", "The response parameter is invalid or malformed."},
      {"bad-request", "The request is invalid or malformed."},
      {"timeout-or-duplicate", "The response is no longer valid: either is too old or has been used previously."}
    ]
    |> Enum.find(fn {er, _msg} -> er == error end)
    |> case do
      nil -> "Unexpected error"
      {_key, value} -> value
    end

    {:error, :verify, error_msg}
  end

end
