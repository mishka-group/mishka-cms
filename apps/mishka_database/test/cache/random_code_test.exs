# defmodule MishkaDatabase.Cache.RandomCodeTest do
#   use ExUnit.Case, async: true
#   doctest MishkaDatabase
#   alias MishkaDatabase.Cache.RandomCode


#   describe "Happy | Random Code (▰˘◡˘▰)" do
#     test "start OTP of random code" do
#       {:error, {:already_started, _pid}} = assert RandomCode.start_link([])
#     end

#     test "save code" do
#       random_code = Enum.random(100000..999999)
#       test_email = "test#{random_code}@test.com"
#       :ok = assert RandomCode.save(test_email, random_code)
#     end

#     test "get user" do
#       random_code = Enum.random(100000..999999)
#       test_email = "test#{random_code}@test.com"
#       :ok = assert RandomCode.save(test_email, "#{random_code}")
#       [{:ok, :get_user, _code, _email}] = assert RandomCode.get_user(test_email, "#{random_code}")
#     end

#     test "delete code" do
#       random_code = Enum.random(100000..999999)
#       test_email = "test#{random_code}@test.com"
#       :ok = assert RandomCode.save(test_email, "#{random_code}")
#       :ok = assert RandomCode.delete_code("#{random_code}", test_email)
#     end

#     test "get code with email" do
#       random_code = Enum.random(100000..999999)
#       test_email = "test#{random_code}@test.com"
#       :ok = assert RandomCode.save(test_email, "#{random_code}")
#       %{code: _code, email: _email, exp: _exp} = assert RandomCode.get_code_with_email(test_email)
#     end
#   end








#   describe "UnHappy | Random Code ಠ╭╮ಠ" do

#   end




# end
