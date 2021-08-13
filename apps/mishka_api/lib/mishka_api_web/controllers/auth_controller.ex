defmodule MishkaApiWeb.AuthController do
  use MishkaApiWeb, :controller

  @allowed_fields ["full_name", "username", "email", "password", "unconfirmed_email"]
  @allowed_fields_output ["full_name", "username", "email", "status"]

  alias MishkaUser.Token.Token

  # add ip limitter and os info
  # this module will help user to send request with his mobile after creating a dynamic plug for mobile provider

  def register(conn, %{"full_name" => _full_name, "username" => _username, "email" => _email , "password" => _password} = params) do

    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })

    MishkaUser.User.create(filtered_params, @allowed_fields)
    |> MishkaApi.AuthProtocol.register(conn, @allowed_fields_output)
  end

  def register(conn, %{"full_name" => _full_name, "username" => _username, "email" => _email} = params) do
    filtered_params = Map.merge(params, %{
      "email" => MishkaHtml.email_sanitize(params["email"]),
      "full_name" => MishkaHtml.full_name_sanitize(params["full_name"]),
      "username" => MishkaHtml.username_sanitize(params["username"]),
      "unconfirmed_email" => MishkaHtml.email_sanitize(params["unconfirmed_email"])
    })

    MishkaUser.User.create(filtered_params, @allowed_fields)
    |> MishkaApi.AuthProtocol.register(conn, @allowed_fields_output)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    to_string(:inet_parse.ntoa(conn.remote_ip))
    with {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_username(MishkaHtml.username_sanitize(username)),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password) do

        MishkaApi.AuthProtocol.login({:ok, user_info, :user}, :login, conn, @allowed_fields_output)
    else
      error_struct ->
        MishkaApi.AuthProtocol.login(error_struct, :login, conn, @allowed_fields_output)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    to_string(:inet_parse.ntoa(conn.remote_ip))
    with {:ok, :get_record_by_field, :user, user_info} <- MishkaUser.User.show_by_email(MishkaHtml.email_sanitize(email)),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password) do

        MishkaApi.AuthProtocol.login({:ok, user_info, :user}, :login, conn, @allowed_fields_output)
    else
      error_struct ->
        MishkaApi.AuthProtocol.login(error_struct, :login, conn, @allowed_fields_output)
    end
  end

  def logout(conn, _params) do
    get_req_header(conn, "authorization")
    |> Token.get_string_token(:refresh)
    |> case do
      {:error, :refresh, action} ->
        {:error, :delete_refresh_token, action}
        |> MishkaApi.AuthProtocol.logout(conn)

      {:ok, :refresh, :valid, refresh_token} ->
        Token.delete_token(refresh_token, MishkaApi.get_config(:token_type))
        |> MishkaApi.AuthProtocol.logout(conn)
    end
  end

  def change_password(conn, %{"curent_password" => password, "new_password" => new_password}) do
    with {:ok, :get_record_by_id, :user, user_info} <- MishkaUser.User.show_by_id(conn.assigns.user_id),
         {:ok, :check_password, :user} <- MishkaUser.User.check_password(user_info, password),
         {:ok, :edit, :user, info} <- MishkaUser.User.edit(%{id: user_info.id, password: new_password}) do

          {:ok, :change_password, info}
          |> MishkaApi.AuthProtocol.change_password(conn, @allowed_fields_output)

    else
      error  ->
        error
        |> MishkaApi.AuthProtocol.change_password(conn, @allowed_fields_output)
    end
  end

  def reset_password(conn, %{"code" => code, "email" => email, "new_password" => password}) do
    MishkaDatabase.Cache.RandomCode.get_user(MishkaHtml.email_sanitize(email), code)
    |> MishkaApi.AuthProtocol.reset_password(conn, password)
  end

  def reset_password(conn, %{"email" => email}) do
    to_string(:inet_parse.ntoa(conn.remote_ip))

    MishkaUser.User.show_by_email(MishkaHtml.email_sanitize(email))
    |> MishkaApi.AuthProtocol.reset_password(conn)
  end

  def user_tokens(conn, _params) do
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.user_tokens(conn, @allowed_fields_output)
  end

  def delete_token(conn, %{"token" => token}) do
    MishkaUser.Token.TokenManagemnt.get_token(conn.assigns.user_id, token)
    |> MishkaApi.AuthProtocol.delete_token(conn.assigns.user_id, conn)
  end

  def delete_tokens(conn, _params) do
    MishkaDatabase.Cache.MnesiaToken.delete_all_user_tokens(conn.assigns.user_id)
    MishkaUser.Token.TokenManagemnt.stop(conn.assigns.user_id)
    # delete all user's Acl
    MishkaUser.Acl.AclManagement.stop(conn.assigns.user_id)
    MishkaApi.AuthProtocol.delete_tokens(conn)
  end

  def get_token_expire_time(conn, %{"token" => token}) do
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.get_token_expire_time(conn, token, @allowed_fields_output)
  end

  def refresh_token(conn, _params) do
    get_req_header(conn, "authorization")
    |> Token.get_string_token(:refresh)
    |> case do
      {:error, :refresh, action} ->
        {:error, :verify_token, :refresh, action}
        |> MishkaApi.AuthProtocol.refresh_token("refresh_token", conn, @allowed_fields_output)

      {:ok, :refresh, :valid, refresh_token} ->
        Token.refresh_token(refresh_token, MishkaApi.get_config(:token_type))
        |> MishkaApi.AuthProtocol.refresh_token(refresh_token, conn, @allowed_fields_output)
    end
  end

  def edit_profile(conn, %{"full_name" => full_name}) do
    MishkaUser.User.edit(%{id: conn.assigns.user_id, full_name: MishkaHtml.full_name_sanitize(full_name)})
    |> MishkaApi.AuthProtocol.edit_profile(conn, @allowed_fields_output)
  end


  def deactive_account(conn, %{"code" => code}) do
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.deactive_account(:sent, {conn, code}, @allowed_fields_output)
  end


  def deactive_account(conn, _params) do
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.deactive_account(:send, conn, @allowed_fields_output)
  end

  def verify_email(conn, %{"code" => code}) do
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.verify_email(:sent, {conn, code}, @allowed_fields_output)
  end

  def verify_email(conn, _params) do
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.verify_email(:send, conn, @allowed_fields_output)
  end


  def verify_email_by_email_link(conn, _params) do
    # this function just is a luncher to send email, the function after clicking we need should be written on html api side
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.verify_email_by_email_link(conn, @allowed_fields_output)
  end


  def send_delete_tokens_link_by_email(conn, %{"email" => email}) do
    # this function just is a luncher to send email, the function after clicking we need should be written on html api side
    MishkaUser.User.show_by_email(email)
    |> MishkaApi.AuthProtocol.send_delete_tokens_link_by_email(conn)
  end

  def deactive_account_by_email_link(conn, _params) do
    # this function just is a luncher to send email, the function after clicking we need should be written on html api side
    MishkaUser.User.show_by_id(conn.assigns.user_id)
    |> MishkaApi.AuthProtocol.deactive_account_by_email_link(conn, @allowed_fields_output)
  end
end
