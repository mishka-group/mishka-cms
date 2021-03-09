defmodule MishkaApiWeb.AuthControllerTest do
  use MishkaApiWeb.ConnCase

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @user_info %{full_name: "test", username: "test", email: "test@test.com", password: "PasswordTest123"}

  describe "Happy | MishkaApi Auth Controller (▰˘◡˘▰)" do

    test "Register", %{conn: conn} do
      conn = post(conn, Routes.auth_path(conn, :register), @user_info)

      assert %{
        "action" => "register",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(conn, 200)
    end

    test "Login", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)

      conn = post(conn, Routes.auth_path(conn, :login), %{username: @user_info.username, password: @user_info.password})

      assert %{
        "action" => "login",
        "auth" => _auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(conn, 200)
    end


    test "Logout", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)


        conn = conn
        |> put_req_header("authorization", "Bearer #{auth["refresh_token"]}")
        |> post(Routes.auth_path(conn, :logout))

        assert %{
          "action" => "logout",
          "message" => _msg,
          "system" => "user"
        } = json_response(conn, 200)

    end

    test "Change Password", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :change_password), %{curent_password: @user_info.password, new_password: "Test123Abs"})


      assert %{
        "action" => "change_password",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn, 200)
    end

    test "Reset Password", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      post(conn, Routes.auth_path(conn, :reset_password), %{email: @user_info.email})
      code = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)
      conn = post(conn, Routes.auth_path(conn, :reset_password), %{code: code.code, email: @user_info.email, new_password: "Test123Abs"})
      assert %{
        "action" => "reset_password",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn, 200)
    end


    test "User Tokens", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

        conn = conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.auth_path(conn, :user_tokens))

        assert %{
          "action" => "user_tokens",
          "message" => _msg,
          "system" => "user",
          "user_info" =>  _user_info,
          "user_tokens_info" => _user_tokens_info
        } = json_response(conn, 200)

    end

    test "Delete Token", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :delete_token), %{token: auth["refresh_token"]})

      assert %{
        "action" => "delete_token",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn, 200)
    end

    test "Delete Tokens", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :delete_tokens))

      assert %{
        "action" => "delete_tokens",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn, 200)
    end

    test "Get Token Expire Time", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :get_token_expire_time), %{token: auth["refresh_token"]})

      assert %{
        "action" => "get_token_expire_time",
        "message" => _,
        "system" => "user",
        "user_info" => _user_info,
        "user_token_info" => _user_token_info
      } = json_response(conn, 200)
    end

    test "Refresh Token", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["refresh_token"]}")
      |> post(Routes.auth_path(conn, :refresh_token))


      assert %{
        "action" => "refresh_token",
        "auth" => _auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info,
      } = json_response(conn, 200)
    end

    test "Edit Profile", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :edit_profile), %{full_name: "test test"})

      assert %{
        "action" => "edit_profile",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn, 200)
    end

    test "Deactive Account", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account))

      code = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account), %{code: code.code})

      assert %{
        "action" => "deactive_account",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn, 200)
    end


    test "Verify Email", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})

      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)


      conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email))

      code = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email), %{code: code.code})

      assert %{
        "action" => "verify_email",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn, 200)
    end

    test "Verify Email by Email Link send request", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})

      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email_by_email_link))

      assert %{
        "action" => "verify_email_by_email_link",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn, 200)
    end

    test "Delete Tokens by Email Link send request", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      conn = conn
      |> post(Routes.auth_path(conn, :delete_tokens_by_email_link), %{email: @user_info.email})

      assert %{
        "action" => "deactive_account_by_email_link",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn, 200)
    end

    test "Deactive Account by Email Link send request", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})

      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)


      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account_by_email_link))

      assert %{
        "action" => "deactive_account_by_email_link",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn, 200)
    end

  end









  describe "UnHappy | MishkaApi Auth Controller ಠ╭╮ಠ" do
    test "Register with password", %{conn: conn} do
      without_user_name = Map.drop(@user_info, [:password]) |> Map.merge(%{full_name: 1, username: 1})
      conn = post(conn, Routes.auth_path(conn, :register), without_user_name)

      assert %{
        "action" => "register",
        "errors" => %{"full_name" => ["is invalid"], "username" => ["is invalid"]},
        "message" => _msg,
        "system" => "user"
      } =  json_response(conn, 400)
    end

    test "Login", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      conn1 = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: "test"})
      conn2 = post(conn, Routes.auth_path(conn, :login), %{username: "username", password: "test"})

      [conn1, conn2]
      |> Enum.map(fn conn ->
        assert %{
          "action" => "login",
          "message" => _msg,
          "system" => "user"
        } = json_response(conn, 401)
      end)


      Enum.map(Enum.shuffle(1..6), fn _x ->
        post(conn, Routes.auth_path(conn, :login), %{username: @user_info.username, password: @user_info.password})
      end)

      conn3 = post(conn, Routes.auth_path(conn, :login), %{username: @user_info.username, password: @user_info.password})
      assert %{
        "action" => "login",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn3, 401)
    end

    test "Logout", %{conn: conn} do
      user_fake = %{id: Ecto.UUID.generate, full_name: "test", username: "test"}
      ref_acc_token = MishkaUser.Token.Token.create_token(user_fake, MishkaApi.get_config(:token_type))


      conn1 = conn
      |> put_req_header("authorization", "Bearer #{ref_acc_token.access_token.token}")
      |> post(Routes.auth_path(conn, :logout))


      assert %{
        "action" => "logout",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn1, 401)

      assert %{
        "action" => "logout",
        "message" => _msg,
        "system" => "user"
      } = json_response(post(conn, Routes.auth_path(conn, :logout)), 401)
    end

    test "Change Password", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn1 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :change_password), %{curent_password: @user_info.password, new_password: "t"})

        %{
          "action" => "change_password",
          "errors" => _errors,
          "message" => _msg,
          "system" => "user"
        } = json_response(conn1, 400)


        conn2 = conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.auth_path(conn, :change_password), %{curent_password: "tEstthis123", new_password: "tEstthis1235"})

        assert %{
          "action" => "change_password",
          "message" => _msg,
          "system" => "user"
        } = json_response(conn2, 401)
    end

    test "Reset Password send request", %{conn: conn} do
      conn1 = post(conn, Routes.auth_path(conn, :reset_password), %{code: "123456", email: "test@test.com", new_password: "password"})
      assert %{
        "action" => "reset_password",
        "message" => _msg,
        "system" => "user"
      } =  json_response(conn1, 404)

      conn2 = post(conn, Routes.auth_path(conn, :reset_password), %{email: "test@test.com"})
      assert %{
        "action" => "reset_password",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn2, 200)

    end


    test "User Tokens", %{conn: conn} do
      id = Ecto.UUID.generate
      user_fake = %{id: id, full_name: "test", username: "#{id}test"}
      ref_acc_token = MishkaUser.Token.Token.create_token(user_fake, MishkaApi.get_config(:token_type))


      conn = conn
      |> put_req_header("authorization", "Bearer #{ref_acc_token.access_token.token}")
      |> post(Routes.auth_path(conn, :user_tokens))

      assert %{
      "action" => "user_tokens",
      "message" => _msg,
      "system" => "user"
      } =  json_response(conn, 401)

    end

    test "Delete Token", %{conn: conn} do
      id = Ecto.UUID.generate
      user_fake = %{id: id, full_name: "test", username: "#{id}test"}
      ref_acc_token = MishkaUser.Token.Token.create_token(user_fake, MishkaApi.get_config(:token_type))


      conn = conn
      |> put_req_header("authorization", "Bearer #{ref_acc_token.access_token.token}")
      |> post(Routes.auth_path(conn, :delete_token), %{token: "token"})

      assert %{
      "action" => "delete_token",
      "message" => _msg,
      "system" => "user"
      } =  json_response(conn, 401)
    end

    test "Delete Tokens", %{conn: conn} do
      id = Ecto.UUID.generate
      user_fake = %{id: id, full_name: "test", username: "#{id}test"}
      ref_acc_token = MishkaUser.Token.Token.create_token(user_fake, MishkaApi.get_config(:token_type))


      conn = conn
      |> put_req_header("authorization", "Bearer #{ref_acc_token.access_token.token}")
      |> post(Routes.auth_path(conn, :delete_tokens))

      assert %{
      "action" => "delete_tokens",
      "message" => _msg,
      "system" => "user"
      } =  json_response(conn, 200)
    end

    test "Get Token Expire Time", %{conn: conn} do
      id = Ecto.UUID.generate
      user_fake = %{id: id, full_name: "test", username: "#{id}test"}
      ref_acc_token = MishkaUser.Token.Token.create_token(user_fake, MishkaApi.get_config(:token_type))


      conn = conn
      |> put_req_header("authorization", "Bearer #{ref_acc_token.access_token.token}")
      |> post(Routes.auth_path(conn, :get_token_expire_time), %{token: ref_acc_token.access_token.token})


      assert %{
        "action" => "get_token_expire_time",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn, 401)
    end




    test "Refresh Token", %{conn: conn} do
      conn1 = conn
      |> post(Routes.auth_path(conn, :refresh_token))
      assert json_response(conn1, 400)




      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

        conn2 = conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.auth_path(conn, :refresh_token))

        assert json_response(conn2, 400)



      post(conn, Routes.auth_path(conn, :register), @user_info)
      Enum.map(Enum.shuffle(1..6), fn _x ->
        post(conn, Routes.auth_path(conn, :login), %{username: @user_info.username, password: @user_info.password})
      end)

      conn3 = post(conn, Routes.auth_path(conn, :login), %{username: @user_info.username, password: @user_info.password})
      assert %{
        "action" => "login",
        "message" => _msg,
        "system" => "user"
      } = json_response(conn3, 401)

    end

    test "Edit Profile", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :edit_profile), %{full_name: "t"})

      assert  %{
        "action" => "edit_profile",
        "errors" => _errors,
        "message" => _msg,
        "system" => "user"
      }  = json_response(conn, 400)
    end


    test "Deactive Account", %{conn: conn} do

      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn1 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account), %{code: "test"})


      assert json_response(conn1, 401)



      conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account))

      code2 = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)

      conn2 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account), %{code: code2.code})

      assert %{
        "action" => "deactive_account",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn2, 200)



      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn3 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account))

      json_response(conn3, 401)
    end


    test "Verify Email", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn1 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email), %{code: "test"})

      assert json_response(conn1, 401)

      conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email))

      code = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)

      conn2 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email), %{code: code.code})

      json_response(conn2, 200)

      conn3 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email))

      json_response(conn3, 401)
    end

    test "Verify Email by Email Link", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})

      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)


      conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email))

      code = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)

      conn1 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email), %{code: code.code})

      assert json_response(conn1, 200)

      conn2 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :verify_email))

      assert json_response(conn2, 401)
    end

    test "Delete Tokens by Email Link" do
      # it dosent need test on controller
    end

    test "Deactive Account by Email Link", %{conn: conn} do
      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account))

      code2 = MishkaDatabase.Cache.RandomCode.get_code_with_email(@user_info.email)

      conn2 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account), %{code: code2.code})

      assert %{
        "action" => "deactive_account",
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info
      } = json_response(conn2, 200)



      post(conn, Routes.auth_path(conn, :register), @user_info)
      login_conn = post(conn, Routes.auth_path(conn, :login), %{email: @user_info.email, password: @user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)

      conn3 = conn
      |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
      |> post(Routes.auth_path(conn, :deactive_account_by_email_link))

      json_response(conn3, 401)
    end



  end


end
