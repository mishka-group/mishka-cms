defmodule MishkaUser.Token.Token do

  alias MishkaUser.Token.{PhoenixToken, JWTToken}

  def create_token(user_info, :phoenix_token) do
    # save tokens on disk db
    PhoenixToken.create_refresh_acsses_token(user_info)
  end

  def create_token(user_info, :jwt_token) do
    # save tokens on disk db
    JWTToken.create_refresh_acsses_token(user_info)
  end

  def refresh_token(refresh_token, :phoenix_token) do
    PhoenixToken.refresh_token(refresh_token)
  end

  def refresh_token(refresh_token, :jwt_token) do
    JWTToken.refresh_token(refresh_token)
  end

  def verify_access_token(token, :phoenix_token) do
    PhoenixToken.verify_token(token, :access)
  end

  def verify_access_token(token, :jwt_token) do
    JWTToken.verify_token(token, :access)
  end
end
