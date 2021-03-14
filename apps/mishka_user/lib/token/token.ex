defmodule MishkaUser.Token.Token do

  alias MishkaUser.Token.{PhoenixToken, JWTToken}

  @type token() :: String.t()
  @type user_info() :: map()
  @type id() :: String.t()
  @type result() :: map() | tuple() | atom()
  @type clime() :: map() | tuple() | struct()

  @spec create_token(user_info(), :jwt_token | :phoenix_token) ::
          {:error, :more_device}
          | {:error, :verify_token, :refresh, :expired | :invalid | :missing | :token_otp_state}
          | %{access_token: %{clime: clime(), token: token()}, refresh_token: %{clime: clime(), token: token()}}

  def create_token(user_info, :phoenix_token) do
    # save tokens on disk db
    PhoenixToken.create_refresh_acsses_token(user_info)
  end

  def create_token(user_info, :jwt_token) do
    # save tokens on disk db
    JWTToken.create_refresh_acsses_token(user_info)
  end


  @spec refresh_token(token(), :jwt_token | :phoenix_token) ::
          {:error, :more_device}
          | {:ok, :delete_old_token, map}
          | {:error, :verify_token, :refresh, result()}
          | %{
              access_token: %{clime: clime(), token: token()},
              refresh_token: %{clime: clime(), token: token()}
            }

  def refresh_token(refresh_token, :phoenix_token) do
    PhoenixToken.refresh_token(refresh_token)
  end

  def refresh_token(refresh_token, :jwt_token) do
    JWTToken.refresh_token(refresh_token)
  end



  @spec verify_access_token(binary, :jwt_token | :phoenix_token) ::
          {:error, :verify_token, atom, result()} | {:ok, :verify_token, atom, map}

  def verify_access_token(token, :phoenix_token) do
    PhoenixToken.verify_token(token, :access)
  end

  def verify_access_token(token, :jwt_token) do
    JWTToken.verify_token(token, :access)
  end



  @spec delete_token(binary, :jwt_token | :phoenix_token) ::
          {:ok, :delete_refresh_token}
          | {:error, :delete_refresh_token, result()}

  def delete_token(token, :phoenix_token) do
    PhoenixToken.delete_refresh_token(token)
  end

  def delete_token(token, :jwt_token) do
    JWTToken.delete_refresh_token(token)
  end

  @spec get_string_token([any], atom()) ::
          {:error, atom(), :invalid | :no_header} | {:ok, atom(), :valid, token()}

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
