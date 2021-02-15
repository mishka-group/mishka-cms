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

  def delete_token(token, :phoenix_token) do
    PhoenixToken.delete_refresh_token(token)
  end

  def delete_token(token, :jwt_token) do
    JWTToken.delete_refresh_token(token)
  end

  def get_string_token([], type), do: {:error, type, :no_header}

  def get_string_token(full_request, type) do
    full_request
    |> List.first()
    |> String.split(" ")
    |> case do
      [""] -> {:error, type, :invalid}
      ["Bearer", token] -> {:ok, type, :valid, token}
      _ -> {:error, type, :invalid}
    end
  end

end
