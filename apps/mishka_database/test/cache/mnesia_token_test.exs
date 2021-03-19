# defmodule MishkaDatabase.Cache.MnesiaTokenTest do
#   use ExUnit.Case #, async: true
#   doctest MishkaDatabase

#   @timeout 5000
#   @save_refresh :timer.seconds(10)

#   # it should be noted, when you run test, it deletes all data of your disk Mnesia
#   # if these data are important please make a backup


#   setup_all do
#     # IO.inspect start_supervised(MishkaDatabase.Cache.MnesiaToken)
#     # pid = case MishkaDatabase.Cache.MnesiaToken.start_link() do
#     #   {:error, {:already_started, pid}} -> pid
#     #   {:ok, pid} -> pid
#     # end
#     # {:ok, pid} =  start_supervised(MishkaDatabase.Cache.MnesiaToken)
#     start_supervised(MishkaDatabase.Cache.MnesiaToken)
#     pid = MishkaDatabase.Cache.MnesiaToken
#     {:ok, pid: pid}
#   end

#   setup do
#     start_supervised(MishkaDatabase.Cache.MnesiaToken)
#     :ok
#   end


#   describe "Happy | OTP Mnesia Token DB (▰˘◡˘▰)" do

#     test "Save a Token", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})
#       Process.send_after(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"}, @save_refresh)
#     end

#     test "Get code with code", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})

#       [
#         [
#           _token_id, _user_id, _token, _exp, _system_time, _os
#         ]
#       ] = assert GenServer.call(context.pid, {:get_token_by_user_id, test_data.user_id})
#     end

#     test "Get token by id", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})

#       [
#         [
#           token_id, _user_id, _token, _exp, _system_time, _os
#         ]
#       ] = assert GenServer.call(context.pid, {:get_token_by_user_id, test_data.user_id})


#       %{id: _id, user_id: _user_id, token: _token, access_expires_in: _exp, create_time: _create_time, os: _os} =
#         assert GenServer.call(context.pid, {:get_token_by_id, token_id}, @timeout)
#     end

#     test "Delete token", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})
#       [
#         [
#           _token_id, _user_id, token, _exp, _system_time, _os
#         ]
#       ] = assert GenServer.call(context.pid, {:get_token_by_user_id, test_data.user_id})
#       :ok = assert GenServer.cast(context.pid, {:delete_token, token})
#     end

#     test "delete_expierd_token", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})
#       :ok =  assert GenServer.cast(context.pid, {:delete_expierd_token, test_data.user_id})
#     end

#     test "delete_all_user_tokens", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})
#       :ok =  assert GenServer.cast(context.pid, {:delete_all_user_tokens, test_data.user_id})
#     end

#     test "delete_all_tokens", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})
#       [] = assert GenServer.call(context.pid, {:delete_all_tokens})
#     end

#     test "stop", context do
#       test_data = creat_test_data()
#       GenServer.cast(context.pid, {:push, test_data.token_id, test_data.user_id, test_data.token, test_data.exp, test_data.system_time, "Linux"})
#       :ok = assert GenServer.cast(context.pid, :stop)
#     end
#   end



#   describe "UnHappy | OTP Mnesia Token DB ಠ╭╮ಠ" do
#     test "Get code with code", context do
#       %{} = assert GenServer.call(context.pid, {:get_token_by_user_id, Ecto.UUID.generate}, @timeout)
#     end

#     test "Get token by id", context do
#       %{} = assert GenServer.call(context.pid, {:get_token_by_id, Ecto.UUID.generate}, @timeout)
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
