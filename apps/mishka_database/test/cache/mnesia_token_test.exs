# defmodule MishkaDatabase.Cache.MnesiaTokenTest do
#   use ExUnit.Case, async: true
#   doctest MishkaDatabase
#   alias MishkaDatabase.Cache.MnesiaToken


#   # it should be noted, when you run test, it deletes all data of your disk Mnesia
#   # if these data are important please make a backup


#   setup do
#     # Supervisor.stop(MishkaDatabase.Cache.MnesiaToken, :normal)
#     stop_supervised(MishkaDatabase.Cache.MnesiaToken)
#     start_supervised(MishkaDatabase.Cache.MnesiaToken)
#     # MnesiaToken.start_link()
#     :ok
#   end


#   describe "Happy | OTP Mnesia Token DB (▰˘◡˘▰)" do

#     test "Save a Token" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")
#        MnesiaToken.save_different_node(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")
#     end

#     test "Get code with code" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")

#       [
#         [
#           _token_id, _user_id, _token, _exp, _system_time, _os
#         ]
#       ] = assert MnesiaToken.get_token_by_user_id(test_data.user_id)
#     end

#     test "Get token by id" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")

#       %{id: _id, user_id: _user_id, token: _token, access_expires_in: _exp, create_time: _create_time, os: _os} = assert MnesiaToken.get_token_by_id(test_data.token_id)
#     end

#     test "Delete token" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux")
#       :ok = assert MnesiaToken.delete_token(test_data.token)
#     end

#     test "delete_expierd_token" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")
#       :ok =  assert MnesiaToken.delete_expierd_token(test_data.user_id)
#     end

#     test "delete_all_user_tokens" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")
#       :ok =  assert MnesiaToken.delete_all_user_tokens(test_data.user_id)
#     end

#     test "delete_all_tokens" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")
#       [] = assert MnesiaToken.delete_all_tokens()
#     end

#     test "stop" do
#       test_data = creat_test_data()
#       :ok = assert MnesiaToken.save(test_data.token_id, test_data.user_id, test_data.token, test_data.system_time, test_data.exp, "Linux")
#       :ok = MnesiaToken.stop()
#     end
#   end



#   describe "UnHappy | OTP Mnesia Token DB ಠ╭╮ಠ" do
#     test "Get code with code" do
#       %{} = assert MnesiaToken.get_token_by_user_id(Ecto.UUID.generate)
#     end

#     test "Get token by id" do
#       %{} = assert MnesiaToken.get_token_by_id(Ecto.UUID.generate)
#     end
#   end

#   def creat_test_data() do
#     token_id = Ecto.UUID.generate()
#     user_id = Ecto.UUID.generate()
#     token = MishkaDatabase.Cache.RandomLink.random_link_id(30)
#     system_time = System.system_time(:second)
#     exp = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.to_unix()
#     %{token_id: token_id, user_id: user_id, token: token, system_time: system_time, exp: exp}
#   end
# end
