defmodule MishkaUserTest.Token.TokenTest do
  use ExUnit.Case, async: true
  doctest MishkaUser

  alias MishkaUser.Token.Token

  describe "Happy | main Token (▰˘◡˘▰)" do
    test "create token" do
      %{
        access_token: _access_token,
        refresh_token: _refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :phoenix_token)

      %{
        access_token: _access_token,
        refresh_token: _refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :jwt_token)
    end

    test "refresh token" do
      %{
        access_token: _access_token,
        refresh_token: refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :phoenix_token)

      %{
        access_token: _access_token,
        refresh_token: _refresh_token
      } = assert Token.refresh_token(refresh_token.token, :phoenix_token)

      %{
        access_token: _access_token,
        refresh_token: jwt_token_refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :jwt_token)

      %{
        access_token: _access_token,
        refresh_token: _refresh_token
      } = assert Token.refresh_token(jwt_token_refresh_token.token, :jwt_token)
    end

    test "verify access token" do
      %{
        access_token: access_token,
        refresh_token: _refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :phoenix_token)

      {:ok, :verify_token, _action, _map} = assert Token.verify_access_token(access_token.token, :phoenix_token)

      %{
        access_token: access_jwt_token,
        refresh_token: _refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :jwt_token)

      {:ok, :verify_token, _action, _map} = assert Token.verify_access_token(access_jwt_token.token, :jwt_token)

    end

    test "delete token" do
      %{
        access_token: _access_token,
        refresh_token: refresh_token
      } = assert Token.create_token(%{id: Ecto.UUID.generate}, :phoenix_token)
      :timer.sleep(1000)

      {:ok, :delete_refresh_token} = assert Token.delete_token(refresh_token.token, :phoenix_token)
    end
  end




  describe "UnHappy | main Token ಠ╭╮ಠ" do
    test "create token" do
      id = Ecto.UUID.generate
      for _item <- Enum.shuffle(1..10) do
        Token.create_token(%{id: id}, :phoenix_token)
      end
      {:error, :more_device} = assert Token.create_token(%{id: id}, :phoenix_token)
    end


    test "refresh token" do

      id = Ecto.UUID.generate
      user_token = Enum.map(Enum.shuffle(1..7), fn _x ->
        :timer.sleep(1000) # make timeout to process difrent node saving on disk
        Token.create_token(%{id: id}, :phoenix_token)
      end)
      |> List.first()

      user_token.refresh_token.token
      |> Token.refresh_token(:phoenix_token)

      clime = user_token.refresh_token.clime
      {:error, :more_device} = assert Token.create_token(%{id: clime["id"]}, :phoenix_token)
    end

    test "verify access token" do
      {:error, :verify_token, _atom, _result} = assert Token.verify_access_token("token", :phoenix_token)
      {:error, :verify_token, _atom, _result} = assert Token.verify_access_token("token", :jwt_token)
    end

    test "delete token" do
      {:error, :delete_refresh_token, _result} = assert Token.delete_token("token", :phoenix_token)
      {:error, :delete_refresh_token, _result} = assert Token.delete_token("token", :jwt_token)
    end
  end
end
