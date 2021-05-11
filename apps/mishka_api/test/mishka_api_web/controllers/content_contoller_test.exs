defmodule MishkaApiWeb.ContentControllerTest do
  use MishkaApiWeb.ConnCase, async: true

  setup_all do
    start_supervised(MishkaDatabase.Cache.MnesiaToken)
    :ok
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  describe "Happy | MishkaApi Content Controller (▰˘◡˘▰)" do
    test "create category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @user_info)

      # assert %{
      #   "action" => "register",
      #   "message" => _msg,
      #   "system" => "user",
      #   "user_info" => _user_info } = json_response(conn, 200)

      IO.inspect json_response(conn, 200)
    end
  end


  describe "UnHappy | MishkaApi Content Controller ಠ╭╮ಠ" do

  end
end
