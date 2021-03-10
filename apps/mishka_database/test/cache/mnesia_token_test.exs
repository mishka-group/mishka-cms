defmodule MishkaDatabase.Cache.MnesiaTokenTest do
  use ExUnit.Case
  doctest MishkaDatabase
  alias MishkaDatabase.Cache.MnesiaToken


  setup do
    MnesiaToken.start_link()
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  describe "Happy | OTP Mnesia Token DB (▰˘◡˘▰)" do

    test "Save a Token" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      # MishkaDatabase.Cache.MnesiaToken.stop()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")
       MnesiaToken.save_different_node(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")
    end


    test "Get code with code" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")

      [
        [
          _token_id, _user_id, _token, _exp, _system_time, _os
        ]
      ] = assert MnesiaToken.get_token_by_user_id(test_data.user_id)
    end

    test "Get token by id" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")

      %{id: _id, user_id: _user_id, token: _token, access_expires_in: _exp, create_time: _create_time, os: _os} = assert MnesiaToken.get_token_by_id(test_data.token_id)
    end

    test "Get all token" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")

      [
        [
          _token_id, _user_id, _token, _exp, _system_time, _os
        ]
      ] = assert MnesiaToken.get_all_token()
    end

    test "Delete token" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")

      [
        [
          _token_id, _user_id, _token, _exp, _system_time, _os
        ]
      ] =  assert MnesiaToken.delete_token(test_data.token)

    end

    test "delete_expierd_token" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")

      [
        [
          _token_id, _user_id, _token, _exp, _system_time, _os
        ]
      ] =  assert MnesiaToken.delete_expierd_token(test_data.user_id)
    end


    test "delete_all_user_tokens" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")


      [
        [
          _token_id, _user_id, _token, _exp, _system_time, _os
        ]
      ] =  MnesiaToken.delete_all_user_tokens(test_data.user_id)


    end


    test "delete_all_tokens" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")
      [
        [
          _token_id, _user_id, _token, _exp, _system_time, _os
        ]
      ] =  MnesiaToken.delete_all_tokens()
    end

    test "stop" do
      MishkaDatabase.Cache.MnesiaToken.delete_all_tokens()
      test_data = creat_test_data()
      :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")
      :ok = MnesiaToken.stop()
    end
  end





  describe "UnHappy | OTP Mnesia Token DB ಠ╭╮ಠ" do

  end


  def creat_test_data() do
    token_id = Ecto.UUID.generate()
    user_id = Ecto.UUID.generate()
    token = MishkaDatabase.Cache.RandomLink.random_link_id(30)
    system_time = System.system_time(:second)
    exp = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.to_unix()
    %{token_id: token_id, user_id: user_id, token: token, system_time: system_time, exp: exp}
  end
end
