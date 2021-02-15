defmodule MishkaApiWeb.AuthController do
  use MishkaApiWeb, :controller

  @allowed_fields ["full_name", "username", "email", "password"]
  @allowed_fields_output ["full_name", "username", "email", "status"]

  alias MishkaUser.Token.Token

  plug MishkaApi.Plug.AccessTokenPlug when action in [:change_password]

  # [:change_password, :user_tokens, :deactive_acount, :edit_profile, :delete_tokens, :get_token_expire_time, :verify_email]

  # action {:login, :add}, error_tag {:user} || %{
  #   0: register 200
  #   1: register 400
  #   2: login 200
  #   3: login 401
  #   none: login 500
  #
  # }
  # create task evry 24 hours to log all registerd user in a day
  # create a task to save all token on database on background
  # add ip limitter
  # this module will help user to send request with his mobile after creating a dynamic plug for mobile provider
  # create a log that coveres all the requested token

  def rgister(conn, %{"full_name" => _full_name, "username" => _username, "email" => _email , "password" => _password} = params) do
    # add ip limitter
    MishkaUser.User.create(params, @allowed_fields)
    |> MishkaApi.ClientAuthProtocol.crud_json(conn, @allowed_fields_output)
  end

  def rgister(conn, %{"full_name" => _full_name, "username" => _username, "email" => _email} = params) do
    # add ip limitter
    MishkaUser.User.create(params, @allowed_fields)
    |> MishkaApi.ClientAuthProtocol.crud_json(conn, @allowed_fields_output)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    to_string(:inet_parse.ntoa(conn.remote_ip))
    # save user os info and user ip
    # add ip limitter and os getter
    with {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_username(username),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password) do

        MishkaApi.ClientAuthProtocol.login_json({:ok, user_info, :user}, :login, conn, @allowed_fields_output)

    else
      error_struct ->
        MishkaApi.ClientAuthProtocol.login_json(error_struct, :login, conn, @allowed_fields_output)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    to_string(:inet_parse.ntoa(conn.remote_ip))
    # save user os info and user ip
    # add ip limitter and os getter
    with {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_email(email),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password) do

        MishkaApi.ClientAuthProtocol.login_json({:ok, user_info, :user}, :login, conn, @allowed_fields_output)

    else
      error_struct ->
        MishkaApi.ClientAuthProtocol.login_json(error_struct, :login, conn, @allowed_fields_output)
    end
  end

  def logout(conn, _params) do
    # add ip limitter and mybe os info
    get_req_header(conn, "authorization")
    |> Token.get_string_token(:refresh)
    |> case do
      {:error, :refresh, action} ->
        {:error, :delete_refresh_token, action}
        |> MishkaApi.ClientAuthProtocol.logout(conn)

      {:ok, :refresh, :valid, refresh_token} ->
        Token.delete_token(refresh_token, :phoenix_token)
        |> MishkaApi.ClientAuthProtocol.logout(conn)
    end
  end

  def change_password(conn, %{"curent_password" => password, "new_password" => new_password}) do
    # {if config} check status of changing password is true
    # then clean all the pass if false just delete this token with user selected os
    # add ip limitter
    with {:ok, :get_record_by_id, :user, user_info} <-MishkaUser.User.show_by_id(conn.assigns.user_id),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password),
         {:ok, :edit, :user, info} <- MishkaUser.User.edit(%{id: user_info.id, password: new_password}) do

          {:ok, :change_password, info}
          |> MishkaApi.ClientAuthProtocol.change_password(conn, @allowed_fields_output)

    else
      error  ->
        error
        |> MishkaApi.ClientAuthProtocol.change_password(conn, @allowed_fields_output)
    end

  end

  def reset_password(_conn, %{"email" => _email}) do
    # add ip limitter
    # if user email and info exist
    # create a random code or big token {this has a config}
    # if random code user can send this to other reset_password action
    # if big tokebn send a link to user email that user can click on it and change password on html api
    # if the html api oky clear the cookies and show a btn which has a mobile url with custom #tag {back to app or other external software}
    # log all the requested reset password if admin allow to save it in db
  end

  def reset_password(_conn, %{"code" => _code, "email" => _email, "new_password" => _password}) do
    # add ip limitter
    # if code and this email exist and true
    # get user id and chnage user password
    # {if config } check the user status if is true delete all the cookies and token, if false just delete this browser sesition
    # send email to user to notic him the password was changed with os and ip info
  end

  def user_tokens(_conn, %{"token" => _token}) do
    # add ip limitter
    # list of user token which dosent show the token
    # show user os recent logined if log is enable
    # and tokens time which were created
    # if this token has the premition
  end

  def deactive_acount(_conn, %{"token" => _token}) do
    # add ip limitter
    # if tokey is verify and user is ok
    # this should be thinked and create way to import on whole the project with a custom privicy
    # this function cant delete all the user data espicaily the data has depency whole the project
    # let the user before the mounth needed on config to active the user after that dont let user to use the acount again
    # send this action log to admin
    # delete all the user's tokens
  end

  def deactive_acount_by_email(_conn, %{"code" => _code}) do
    # get request without ssetion
    # the link whitch is clicked by user
  end

  def edit_profile(_conn, %{"token" => _token, "profile_info" => _profile_info}) do
    # add ip limitter
    # after creating user profile table
    # if user token verify and user is ok
    # if config allow to send profile info
    # try to get safe profile daynamic infos
    # I think there is a good place to get mobile and verify
  end

  def delete_tokens(_conn, %{"token" => _token}) do
    # add ip limiter
    # if token is verify and user is oky
    # send a random code or big token with chacking config
  end

  def delete_tokens(_conn, %{"code" => _code}) do
    # get request without ssetion
    # the link whitch is clicked by user
  end


  def delete_tokens(_conn, %{"token" => _token, "code" => _code}) do
    # add ip limiter
    # if token is verify and user is oky
    # if user code is verify
    # delete all the user token created
    # clear user cookins and extra
  end

  def delete_tokens_by_email(_conn, %{"email" => _email}) do
    # get request without ssetion
    # the link whitch is clicked by user
  end

  def get_token_expire_time(_conn, %{"token" => _token}) do
    # add ip limiter
    # if user token and user is ok
    # show user exprie time
  end

  def refresh_token(conn, _params) do
    # add ip limiter
    get_req_header(conn, "authorization")
    |> Token.get_string_token(:refresh)
    |> case do
      {:error, :refresh, action} ->
        {:error, :verify_token, :refresh, action}
        |> MishkaApi.ClientAuthProtocol.refresh_token("refresh_token", conn, @allowed_fields_output)

      {:ok, :refresh, :valid, refresh_token} ->
        Token.refresh_token(refresh_token, :phoenix_token)
        |> MishkaApi.ClientAuthProtocol.refresh_token(refresh_token, conn, @allowed_fields_output)
    end
  end

  def verify_email(_conn, %{"token" => _token}) do
    # add ip limiter
    # if token and user is ok
    # if email is not active
    # send email {on config} big token or random code
  end

  def verify_email(_conn, %{"token" => _token, "code" => _code}) do
    # add ip limiter
    # if token and user is ok
    # if email is not active
    # if code is valid; verify email
  end

end
