defprotocol MishkaApi.AuthProtocol do
  @fallback_to_any true
  @doc "should be changed"

  def register(crud_struct, conn, allowed_fields)

  def login(request_struct, action, conn, allowed_fields)

  def refresh_token(outputs, token, conn, allowed_fields)

  def logout(outputs, conn)

  def change_password(outputs, conn, allowed_fields)

  def user_tokens(outputs, conn, allowed_fields_output)

  def get_token_expire_time(outputs, conn, token, allowed_fields_output)

  def reset_password(outputs, conn)

  def reset_password(outputs, conn, password)

  def delete_token(outputs, id, conn)

  def delete_tokens(conn)

  def edit_profile(outputs, conn, allowed_fields_output)

  def deactive_account(outputs, action, conn, allowed_fields_output)

  def verify_email(outputs, action, conn, allowed_fields_output)

  def verify_email_by_email_link(outputs, conn, allowed_fields_output)

  def deactive_account_by_email_link(outputs, conn, allowed_fields_output)

  def delete_tokens_by_email_link(outputs, conn)
end

defimpl MishkaApi.AuthProtocol, for: Any do
  use MishkaApiWeb, :controller
  alias MishkaUser.Token.Token
  alias MishkaDatabase.Cache.{RandomCode, RandomLink}

  @request_error_tag :user

  def register({:error, _action, _error_tag, repo_error}, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :register,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def register({:ok, _action, _error_tag, repo_data}, conn, allowed_fields) do
    MishkaUser.Identity.create(%{user_id: repo_data.id, identity_provider: :self})
    conn
    |> put_status(200)
    |> json(%{
      action: :register,
      system: @request_error_tag,
      message: "داده شما با موفقیت ذخیره شد.",
      user_info: Map.take(repo_data, allowed_fields |> Enum.map(&String.to_existing_atom/1))
    })
  end

  def login({:ok, user_info, _error_tag}, action, conn, allowed_fields) do
    case token = Token.create_token(user_info, MishkaApi.get_config(:token_type)) do
      {:error, :more_device} ->

        MishkaUser.Token.TokenManagemnt.get_all(user_info.id)

        login({:error, :more_device, :user}, action, conn, allowed_fields)

      _ ->

        conn
        |> put_status(200)
        |> json(%{
          action: :login,
          system: @request_error_tag,
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


  def login(error_struct, _action, conn, _allowed_fields) do
    case error_struct do
      {:error, :get_record_by_field, _error_tag} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :login,
          system: @request_error_tag,
          message: "این خطا در زمانی روخ می دهد که اطلاعات حساب کاربری خودتان را به اشتباه ارسال کرده باشد. لطفا دوباره با دقت بیشتر اطلاعات ورود به سیستم را وارد کنید."
        })

      {:error, :check_password, _error_tag} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :login,
          system: @request_error_tag,
          message: "این خطا در زمانی روخ می دهد که اطلاعات حساب کاربری خودتان را به اشتباه ارسال کرده باشد. لطفا دوباره با دقت بیشتر اطلاعات ورود به سیستم را وارد کنید."
        })

      {:error, :more_device, _error_tag} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :login,
          system: @request_error_tag,
          message: "با حساب کاربری شما بیشتر از 5 دستگاه وارد سیستم شدند. برای ورود باید از یکی از دستگاه ها خارج شوید و اگر خودتان وارد نشدید سریعا پسورد خود را تغییر داده و همینطور تمام توکن ها را درحساب کاربری خود حذف نمایید."
        })

      _ ->
        conn
        |> put_status(500)
        |> json(%{
          action: :login,
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

  def refresh_token({:error, :verify_token, :refresh, _result}, _token, conn, _allowed_fields) do
    conn
    |> put_status(400)
    |> json(%{
      action: :refresh_token,
      system: @request_error_tag,
      message: " توکن ارسالی اشتباه می باشد یا منقضی گردیده است"
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
      message: "شما با موفقیت از سیستم خارج  شدید"
    })
  end

  def logout({:error, :delete_refresh_token, _action}, conn) do
    conn
    |> put_status(401)
    |> json(%{
      action: :logout,
      system: @request_error_tag,
      message: "این خطا در زمانی روخ می دهد که توکن شما معتبر نباشد یا قبلا از سیستم پاک شده باشد."
    })
  end

  def change_password({:ok, :change_password, info}, conn, allowed_fields) do
    # clean all the token otp
    MishkaUser.Token.TokenManagemnt.stop(info.id)
    # clean all the token on disc
    MishkaDatabase.Cache.MnesiaToken.delete_all_user_tokens(info.id)

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


  def user_tokens({:ok, :get_record_by_id, :user, user_info}, conn, allowed_fields_output) do
    conn
    |> put_status(200)
    |> json(%{
      action: :user_tokens,
      system: @request_error_tag,
      message: "توکن شما با موفقیت تازه سازی گردید. و توکن قبلی نیز حذف شد.",
      user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1)),
      user_tokens_info:

      MishkaUser.Token.TokenManagemnt.get_all(user_info.id)
      |> MishkaUser.Token.TokenManagemnt.get_token_info()
      |> Enum.map(fn x ->
        %{
          access_expires_in: x.access_expires_in,
          create_time: x.create_time,
          last_used: x.last_used,
          os: x.os,
          type: x.type
        }
      end)
    })
  end


  def user_tokens({:error, :get_record_by_id, :user}, conn, _allowed_fields_output) do
    conn
    |> put_status(401)
    |> json(%{
      action: :user_tokens,
      system: @request_error_tag,
      message: "کاربر مورد نظر ممکن است از سیستم حذف شده بشد یا دسترسی آن قطع گردیده"
    })
  end

  def get_token_expire_time({:ok, :get_record_by_id, :user, user_info}, conn, token, allowed_fields_output) do
    token_allowed_filed = ["access_expires_in", "create_time", "last_used", "os", "token", "type"]
    conn
    |> put_status(200)
    |> json(%{
      action: :get_token_expire_time,
      system: @request_error_tag,
      message: "توکن شما با موفقیت در سیستم اسکن گردید",
      user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1)),
      user_token_info:
      case MishkaUser.Token.TokenManagemnt.get_token(user_info.id, token) do
        nil -> nil
        token_info -> Map.take(token_info, token_allowed_filed |> Enum.map(&String.to_existing_atom/1))
      end
    })
  end


  def get_token_expire_time({:error, :get_record_by_id, :user}, conn, _token, _allowed_fields_output) do
    conn
    |> put_status(401)
    |> json(%{
      action: :get_token_expire_time,
      system: @request_error_tag,
      message: "کاربر مورد نظر ممکن است از سیستم حذف شده بشد یا دسترسی آن قطع گردیده"
    })
  end


  def reset_password({:ok, :get_record_by_field, :user, user_info}, conn) do
    random_code = Enum.random(100000..999999)
    case RandomCode.get_code_with_email(user_info.email) do
      nil ->
        RandomCode.save(user_info.email, random_code)
        # send random code to user email

      _user_data ->
        RandomCode.save(user_info.email, random_code)
    end

    conn
    |> put_status(200)
    |> json(%{
      action: :reset_password,
      system: @request_error_tag,
      message: "در صورتی که ایمیل شما در سیستم موجود باشد یک ایمیل حاوی تغییر پسورد برای شما ارسال می گردد. لطفا در صورت عدم وجود ایمیل در اینباکس لطفا در پوشه اسپم یا جانک نیز بازدید به عمل بیاورید"
    })
  end

  def reset_password({:error, :get_record_by_field, _error_tag}, conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :reset_password,
      system: @request_error_tag,
      message: "در صورتی که ایمیل شما در سیستم موجود باشد یک ایمیل حاوی تغییر پسورد برای شما ارسال می گردد. لطفا در صورت عدم وجود ایمیل در اینباکس لطفا در پوشه اسپم یا جانک نیز بازدید به عمل بیاورید"
    })
  end

  def reset_password([{:error, :get_user, _error_result}], conn, _password) do
    conn
    |> put_status(404)
    |> json(%{
      action: :reset_password,
      system: @request_error_tag,
      message: "این خطا در زمانی روخ می دهد که کد ریست پسورد اشتباه باشد یا وجود نداشته باشد."
    })
  end


  def reset_password([{:ok, :get_user, code, email}], conn, password) do

    with {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_email(email),
         {:ok, :edit, :user, _user_edit_info} <- MishkaUser.User.edit(%{id: user_info.id, password: password}) do

          # clean all the token OTP
          MishkaUser.Token.TokenManagemnt.stop(user_info.id)
          # clean all the token on disc
          MishkaDatabase.Cache.MnesiaToken.delete_all_user_tokens(user_info.id)
          # delete all randome codes of user
          RandomCode.delete_code(code, email)

        conn
        |> put_status(200)
        |> json(%{
          action: :reset_password,
          system: @request_error_tag,
          message: "پسورد شما با موفقیت ریست شد و تمامی توکن های ایجاد شده برای حساب کاربری شما نیز منقضی گردید"
        })

    else
      {:error, :get_record_by_field, error_tag} ->
        reset_password({:error, :get_record_by_field, error_tag}, conn)

      {:error, :edit, :user, repo_error} ->
        change_password({:error, :edit, :user, repo_error}, conn, "allowed_fields")
    end
  end

  def delete_token(nil, _id, conn) do
    conn
    |> put_status(401)
    |> json(%{
      action: :delete_token,
      system: @request_error_tag,
      message: "این خطا در زمانی روخ می دهد که توکن ارسالی وجود نداشته باشد"
    })
  end

  def delete_token(token, user_id, conn) do
    if token.type == "refresh" do
      MishkaUser.Token.TokenManagemnt.delete_child_token(user_id, token.token)
      MishkaDatabase.Cache.MnesiaToken.delete_token(token)
    end

    MishkaUser.Token.TokenManagemnt.delete_token(user_id, token.token)

    conn
    |> put_status(200)
    |> json(%{
      action: :delete_token,
      system: @request_error_tag,
      message: "توکن شما با موفقیت از سیستم حذف گردید. باید توجه داشته باشید تمامی دستگاه هایی که از این توکن استفاده می کردند نیز به صورت خودکار خارج شدند و برای ورود مجدد لطفا دوباره در سیستم لاگین کنید."
    })
  end


  def delete_tokens(conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :delete_tokens,
      system: @request_error_tag,
      message: "توکن های شما با موفقیت حذف گردید"
    })
  end

  def edit_profile({:ok, :edit, :user, user_info}, conn, allowed_fields_output) do
    # after we create dynamic profile we can do more than now
    conn
    |> put_status(200)
    |> json(%{
      action: :edit_profile,
      system: @request_error_tag,
      message: ".اطلاعات کاربر مورد نظر با موفقیت ویرایش گردید",
      user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
    })
  end

  def edit_profile({:error, :edit, :user, repo_error}, conn, _allowed_fields_output) do
    conn
    |> put_status(400)
    |> json(%{
      action: :edit_profile,
      system: @request_error_tag,
      message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
      errors: MishkaDatabase.translate_errors(repo_error)
    })
  end

  def edit_profile({:error, :edit, _action, _error_tag}, conn, _allowed_fields_output) do
    conn
    |> put_status(401)
    |> json(%{
      action: :edit_profile,
      system: @request_error_tag,
      message: "کاربر مذکور وجود ندارد یا از یستم حذف گردید"
    })
  end

  def deactive_account({:ok, :get_record_by_id, _user, user_info}, :send, conn, allowed_fields_output) do
    case user_info.status do
      :inactive  ->

        conn
        |> put_status(401)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "حساب کاربری شما از قبل غیر فعال سازی گردیده است. اطلاعات تکمیلی در زمان درخواست غیر فعال سازی برای شما ایمیل گردید."
        })

      _data ->
        # send random code to user's email
        random_code = Enum.random(100000..999999)
        RandomCode.save(user_info.email, random_code)
        conn
        |> put_status(200)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "کد غیر فعال سازی حساب کاربری برای شما ارسال گردید. لطفا ایمیل خود را چک نمایید.",
          user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
        })
    end
  end


  def deactive_account({:error, :get_record_by_id, _error_tag}, :send, conn, _allowed_fields_output) do
    conn
    |> put_status(404)
    |> json(%{
      action: :deactive_account,
      system: @request_error_tag,
      message: "این خطا در زمانی روخ می هد که کاربری وجود نداشته باشد یا از سیستم حذف گریده باشد."
    })
  end

  def deactive_account({:ok, :get_record_by_id, _user, user_info}, :sent, {conn, code}, allowed_fields_output) do

    with [{:ok, :get_user, _code, _email}] <- MishkaDatabase.Cache.RandomCode.get_user(user_info.email, code),
         {:error, :active?, _status} <- MishkaUser.User.active?(user_info.status),
         {:ok, :edit, _error_tag, repo_data} <- MishkaUser.User.edit(%{id: user_info.id, status: :inactive}) do

          RandomCode.delete_code(code, user_info.email)
          MishkaDatabase.Cache.MnesiaToken.delete_all_user_tokens(user_info.id)
          MishkaUser.Token.TokenManagemnt.stop(user_info.id)

          conn
          |> put_status(200)
          |> json(%{
            action: :deactive_account,
            system: @request_error_tag,
            message: "حساب شما با موفقیت غیر فعال شد. ایمیلی در رابطه با چگونگی پاک سازی اطلاعات شما ارسال گردیده است. لازم به ذکر هست تمامی دستگاه های آنلاین شما به سیستم نیز خودکار خارج شدند. برای اتصال مجدد دوباره لاگین کنید",
            user_info: Map.take(repo_data, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
          })

    else
      {:error, :edit, _error_tag, repo_error} ->
        conn
        |> put_status(400)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
          errors: MishkaDatabase.translate_errors(repo_error)
        })

      {:error, :edit, _acction, _error_tag} ->

        conn
        |> put_status(401)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "این خطا در زمانی روخ می دهد که حساب کاربری شما در سایت وجود نداشته باشد یا از سیستم حذف گردیده باشد."
        })

      [{:error, :get_user, :time}] ->
        conn
        |> put_status(401)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "کد فعال سازی شما منقضی شده است."
        })

      [{:error, :get_user, _acction}] ->
        conn
        |> put_status(401)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "کد غیر فعال سازی شما اشتباه است یا در سیستم برای حساب کاربری شما کدی ثبت نشده است. لطفا دوباره درخواست جدید ثبت کنید."
        })

      {:ok, :active?, :inactive} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :deactive_account,
          system: @request_error_tag,
          message: "حساب کاربری شما از قبل غیر فعال سازی گردیده است. اطلاعات تکمیلی در زمان درخواست غیر فعال سازی برای شما ایمیل گردید."
        })
    end
  end

  def verify_email({:ok, :get_record_by_id, _user, user_info}, :sent, {conn, code}, allowed_fields_output) do
    with [{:ok, :get_user, _code, _email}] <- MishkaDatabase.Cache.RandomCode.get_user(user_info.email, code),
         {:error, :active?, _status} <- MishkaUser.User.active?(user_info.status),
         {:ok, :edit, _error_tag, repo_data} <- MishkaUser.User.edit(%{id: user_info.id, status: :active, unconfirmed_email: nil}) do

          RandomCode.delete_code(code, user_info.email)

          conn
          |> put_status(200)
          |> json(%{
            action: :verify_email,
            system: @request_error_tag,
            message: "حساب شما با موفقیت فعال شد.",
            user_info: Map.take(repo_data, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
          })

    else
      {:error, :edit, _error_tag, repo_error} ->
        conn
        |> put_status(400)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "خطایی در ذخیره سازی داده های شما روخ داده است.",
          errors: MishkaDatabase.translate_errors(repo_error)
        })

      {:error, :edit, _acction, _error_tag} ->

        conn
        |> put_status(401)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "این خطا در زمانی روخ می دهد که حساب کاربری شما در سایت وجود نداشته باشد یا از سیستم حذف گردیده باشد."
        })

      [{:error, :get_user, :time} ]->
        conn
        |> put_status(401)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "کد فعال سازی شما منقضی شده است."
        })

      [{:error, :get_user, _acction} ]->
        conn
        |> put_status(401)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "کد فعال سازی شما اشتباه است یا در سیستم برای حساب کاربری شما کدی ثبت نشده است. لطفا دوباره درخواست جدید ثبت کنید."
        })

      {:ok, :active?, :active} ->
        conn
        |> put_status(401)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "حساب کاربری شما از قبل فعال سازی گردیده است."
        })
    end
  end

  def verify_email({:ok, :get_record_by_id, _user, user_info}, :send, conn, allowed_fields_output) do
    case user_info.status do
      :active  ->

        conn
        |> put_status(401)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "حساب کاربری شما از قبل فعال شده است"
        })

      _data ->
        # send random code to user's email
        random_code = Enum.random(100000..999999)
        RandomCode.save(user_info.email, random_code)
        conn
        |> put_status(200)
        |> json(%{
          action: :verify_email,
          system: @request_error_tag,
          message: "کد فعال سازی حساب کاربری برای شما ارسال گردید. لطفا ایمیل خود را چک نمایید.",
          user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
        })
    end
  end

  def verify_email_by_email_link({:ok, :get_record_by_id, _user, user_info}, conn, allowed_fields_output) do
    case user_info.status do
      :active  ->
        conn
        |> put_status(401)
        |> json(%{
          action: :verify_email_by_email_link,
          system: @request_error_tag,
          message: "حساب کاربری شما از قبل فعال گردیده است."
        })

      _ ->
        RandomLink.save(user_info.email, %{type: :verify})
        # Email sender module with theme
        conn
        |> put_status(200)
        |> json(%{
          action: :verify_email_by_email_link,
          system: @request_error_tag,
          message: "لینک فعال سازی حساب کاربری برای شما ایمیل  گردید. لطفا ایمیل خود را چک نمایید.",
          user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
        })

    end
  end

  def verify_email_by_email_link(_, conn, _allowed_fields_output) do
    conn
    |> put_status(404)
    |> json(%{
      action: :verify_email_by_email_link,
      system: @request_error_tag,
      message: "چنین کاربری وجود ندارد یا از سیستم حذف گردیده"
    })
  end

  def deactive_account_by_email_link({:ok, :get_record_by_id, _user, user_info}, conn, allowed_fields_output) do
    case user_info.status do
      :inactive ->
        RandomLink.save(user_info.email, %{type: :deactive})
        # Email sender module with theme
        conn
        |> put_status(401)
        |> json(%{
          action: :deactive_account_by_email_link,
          system: @request_error_tag,
          message: "حساب کاربری شما از قبل غیر فعال گردیده است."
        })


      _ ->
        RandomLink.save(user_info.email, %{type: :deactive})
        # Email sender module with theme
        conn
        |> put_status(200)
        |> json(%{
          action: :deactive_account_by_email_link,
          system: @request_error_tag,
          message: "ایمیل غیر فعال سازی حساب کاربری برای شما ارسال گردید",
          user_info: Map.take(user_info, allowed_fields_output |> Enum.map(&String.to_existing_atom/1))
        })
    end
  end

  def deactive_account_by_email_link(_, conn, _allowed_fields_output) do
    conn
    |> put_status(404)
    |> json(%{
      action: :deactive_account_by_email_link,
      system: @request_error_tag,
      message: "چنین کاربری وجود ندارد یا از سیستم حذف گردیده"
    })
  end

  def delete_tokens_by_email_link({:ok, :get_record_by_field, :user, user_info}, conn) do
    RandomLink.save(user_info.email, %{type: :delete_tokens})
    # Email sender module with theme
    conn
    |> put_status(200)
    |> json(%{
      action: :deactive_account_by_email_link,
      system: @request_error_tag,
      message: "اگر در بانک اطلاعاتی ما حسابی داشته باشید برای شما یک ایمیل حاوی لینک ارسال می گردد."
    })
  end

  def delete_tokens_by_email_link(_, conn) do
    conn
    |> put_status(200)
    |> json(%{
      action: :deactive_account_by_email_link,
      system: @request_error_tag,
      message: "اگر در بانک اطلاعاتی ما حسابی داشته باشید برای شما یک ایمیل حاوی لینک ارسال می گردد."
    })
  end

end
