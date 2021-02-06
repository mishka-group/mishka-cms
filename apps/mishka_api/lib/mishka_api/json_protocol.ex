defprotocol MishkaApi.JsonProtocol do
  @fallback_to_any true
  @doc "should be changed"
  def crud_json(crud_struct, conn, allowed_fields)

  def login_json(request_struct, action, conn, allowed_fields)
end

defimpl MishkaApi.JsonProtocol, for: Tuple do
  use MishkaApiWeb, :controller
  alias MishkaUser.Token.Token

  def crud_json({:error, action, error_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: action,
      system: error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def crud_json({:ok, action, error_tag, repo_data}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: action,
      system: error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      user_info: Map.take(repo_data, allowed_fields |> Enum.map(&String.to_existing_atom/1))
    })
  end

  def login_json({:ok, user_info, error_tag}, action, conn, allowed_fields) do
    case token = Token.create_refresh_acsses_token(user_info) do
      {:error, :more_device} ->
        login_json({:error, :more_device, :user}, action, conn, allowed_fields)

      _ ->

        conn
        |> put_status(200)
        |> json(%{
          action: action,
          system: error_tag,
          message: "با موفقیت وارد سیستم شدید.",
          user_info: Map.take(user_info, allowed_fields |> Enum.map(&String.to_existing_atom/1)),
          auth: %{

            refresh_token: token.refresh_token.token,
            refresh_expires_in: token.refresh_token.clime["exp"],
            refresh_token_type: token.refresh_token.clime["typ"],

            access_token: token.access_token.token,
            access_expires_in: token.access_token.clime["exp"],
            access_token_type: token.access_token.clime["typ"],
          }
        })
    end
  end


  def login_json(error_struct, action, conn, _allowed_fields) do
    case error_struct do
      {:error, :get_record_by_field, error_tag} ->
        conn
        |> put_status(401)
        |> json(%{
          action: action,
          system: error_tag,
          message: "ممکن است اطلاعات حسابکاربری شما اشتباه باشد."
        })

      {:error, :check_password, error_tag} ->
        conn
        |> put_status(401)
        |> json(%{
          action: action,
          system: error_tag,
          message: "این خطا در زمانی روخ می دهد که اطلاعات حساب کاربری خودتان را به اشتباه ارسال کرده باشد. لطفا دوباره با دقت بیشتر اطلاعات ورود به سیستم را وارد کنید."
        })

      {:error, :more_device, error_tag} ->
        conn
        |> put_status(401)
        |> json(%{
          action: action,
          system: error_tag,
          message: "با حساب کاربری شما بیشتر از 5 دستگاه وارد سیستم شدند. برای ورود باید از یکی از دستگاه ها خارج شوید و اگر خودتان وارد نشدید سریعا پسورد خود را تغییر داده و همینطور تمام توکن ها را درحساب کاربری خود حذف نمایید."
        })


      _ ->
        conn
        |> put_status(500)
        |> json(%{
          action: action,
          system: :user,
          message: "خطای غیر قابل پیشبینی روخ داده است."
        })
    end
  end


end
