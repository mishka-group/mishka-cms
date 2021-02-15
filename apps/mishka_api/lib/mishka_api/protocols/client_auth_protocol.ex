defprotocol MishkaApi.ClientAuthProtocol do
  @fallback_to_any true
  @doc "should be changed"

  def crud_json(crud_struct, conn, allowed_fields)

  def login_json(request_struct, action, conn, allowed_fields)

  def refresh_token(outputs, token, conn, allowed_fields)

  def logout(outputs, conn)

  def change_password(outputs, conn, allowed_fields)
end

defimpl MishkaApi.ClientAuthProtocol, for: Any do
  use MishkaApiWeb, :controller
  alias MishkaUser.Token.Token

  @request_error_tag :user

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
    case token = Token.create_token(user_info, :phoenix_token) do
      {:error, :more_device} ->

        MishkaUser.Token.TokenManagemnt.get_all(user_info.id)

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
          system: @request_error_tag,
          message: "خطای غیر قابل پیشبینی روخ داده است."
        })
    end

  end

  def refresh_token({:error, :more_device}, _token, conn, _allowed_fields) do
    conn
    |> put_status(301)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "شما بیشتر از پنج بار در سیستم وارد شدید. لطفا برای ورود جدید از یکی از سیستم های لاگین شده خارج شوید."
    })
  end

  def refresh_token({:error, :verify_token, :refresh, :expired}, _token, conn, _allowed_fields) do
    conn
    |> put_status(401)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "توکن ارسالی منقضی شده است."
    })
  end

  def refresh_token({:error, :verify_token, :refresh, :invalid}, _token, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "توکن ارسالی اشتباه می باشد."
    })
  end

  def refresh_token({:error, :verify_token, :refresh, :missing}, _token, conn, _allowed_fields) do
    conn
    |> put_status(301)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "توکن ارسالی ممکن است اشتباه باشد یا از سیستم حذف شده است."
    })
  end

  def refresh_token({:error, :verify_token, :refresh, :token_otp_state}, _token, conn, _allowed_fields) do
    conn
    |> put_status(404)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "توکن ارسالی ممکن است اشتباه باشد یا از سیستم حذف شده است."
    })
  end

  def refresh_token({:error, :verify_token, :refresh, :no_header}, _token, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "لطفا بر اساس مستندات توکن درخواستی را در هدر ارسال نمایید."
    })
  end

  def refresh_token(%{refresh_token: %{token: refresh_token, clime: refresh_clime},
                      access_token:  %{token: access_token, clime: access_clime}}, _token, conn, allowed_fields) do


    {:ok, :get_record_by_id, :user, user_info} = MishkaUser.User.show_by_id(refresh_clime["id"])


    conn
    |> put_status(200)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: "توکن شما با موفقیت تازه سازی گردید. و توکن قبلی نیز حذف شد.",
      user_info: Map.take(user_info, allowed_fields |> Enum.map(&String.to_existing_atom/1)),
      auth: %{

        refresh_token: refresh_token,
        refresh_expires_in: refresh_clime["exp"],
        refresh_token_type: refresh_clime["typ"],

        access_token: access_token,
        access_expires_in: access_clime["exp"],
        access_token_type: access_clime["typ"],
      }
    })
  end

  def logout({:ok, :delete_refresh_token}, conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :logout,
      system: @request_error_tag,
      message: "توکن شما با موفقیت تازه سازی گردید. و توکن قبلی نیز حذف شد."
    })
  end

  def logout({:error, :delete_refresh_token, action}, conn) do
    conn
    |> put_status(401)
    |> json(%{
      action: action,
      system: @request_error_tag,
      message: "این خطا در زمانی روخ می دهد که توکن شما معتبر نباشد یا قبلا از سیستم پاک شده باشد."
    })
  end

  def change_password({:ok, :change_password, info}, conn, allowed_fields) do
    conn
    |> put_status(200)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      user_info: Map.from_struct(info) |> Map.take(allowed_fields  |> Enum.map(&String.to_existing_atom/1)),
      message: "پسورد کاربر با موفقیت تغییر کرد. تمامی توکن های کاربر پاک گردید لطفا دوباره وارد دستگاه های موردنظر خود با پسورد جدید شوید."
    })
  end

  def change_password({:error, :get_record_by_id, :user}, conn, _allowed_fields) do
    conn
    |> put_status(404)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      message: "چنین کاربری وجود ندارد."
    })
  end

  def change_password({:error, :check_password, :user}, conn, _allowed_fields) do
    conn
    |> put_status(401)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      message: "پسورد کنونی شما اشتباه می باشد لطفا با دقت دوباره ارسال فرمایید."
    })
  end

  def change_password({:error, :edit, :uuid, :user}, conn, _allowed_fields) do
    conn
    |> put_status(404)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      message: "شناسه وارد شده کاربر اشتباه می باشد یا از سیستم حذف گردیده است.",
    })
  end

  def change_password({:error, :edit, :get_record_by_id, :user} , conn, _allowed_fields) do
    conn
    |> put_status(404)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      message: "شناسه وارد شده کاربر اشتباه می باشد یا از سیستم حذف گردیده است.",
    })
  end

  def change_password({:error, :edit, :user, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def change_password(_error, conn, _allowed_fields) do
    conn
    |> put_status(500)
    |> json(%{
      action: :change_password,
      system: @request_error_tag,
      message: "خطای غیرقابل پیشبینی روخ داده است."
    })
  end


end
