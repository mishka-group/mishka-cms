defmodule MishkaApiWeb.ContentControllerTest do
  use MishkaApiWeb.ConnCase, async: true

  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post
  alias MishkaContent.Blog.Like

  setup_all do
    start_supervised(MishkaDatabase.Cache.MnesiaToken)
    :ok
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @category_info %{
    title: "Blog Category title test",
    short_description: "this is a test short description",
    main_image: "../image.png",
    header_image: "../image.png",
    description: "this is a test description",
    alias_link: "content-blog-category-link"
  }

  @post_info %{
    title: "Test Post",
    short_description: "Test post description",
    main_image: "https://test.com/png.png",
    description: "Test post description",
    status: :active,
    priority: :none,
    alias_link: "test-post-test",
    robots: :IndexFollow,
  }

  @right_user_info %{
    "full_name" => "username",
    "username" => "usernameuniq_#{Enum.random(100000..999999)}",
    "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
    "password" => "pass1Test",
    "status" => 1,
    "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
  }

  setup _context do
    conn = Phoenix.ConnTest.build_conn()
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    login_conn = post(conn, Routes.auth_path(conn, :login), %{email: user_info.email, password: user_info.password})
      assert %{
        "action" => "login",
        "auth" => auth,
        "message" => _msg,
        "system" => "user",
        "user_info" => _user_info } = json_response(login_conn, 200)
    %{conn: conn, user_info: user_info, auth: auth}
  end

  describe "Happy | MishkaApi Content Controller (▰˘◡˘▰)" do
    test "create category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), @category_info)

      assert %{
        "action" => "create_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn, 200)
    end

    test "edit category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_category), %{category_id: category_info["id"], title: "title edit test"})

      assert %{
        "action" => "edit_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)
    end

    test "delete category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)

      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_category), %{category_id: category_info["id"]})
      assert %{
        "action" => "delete_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)
    end

    test "destroy category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)

      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :destroy_category), %{category_id: category_info["id"]})
      assert %{
        "action" => "destroy_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)
    end

    test "category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :category), %{category_id: category_info["id"]})

      assert %{
        "action" => "category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)

      new_conn1 = Phoenix.ConnTest.build_conn()
      conn2 =
        new_conn1
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :category), %{alias_link: category_info["alias_link"]})
      assert %{
        "action" => "category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn2, 200)
    end

    test "categories", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :categories), %{})
      assert %{
        "action" => "categories",
        "system" => "content",
        "message" => _msg,
        "categories" => _category_info
      } = json_response(conn1, 200)

      new_conn1 = Phoenix.ConnTest.build_conn()
      conn2 =
        new_conn1
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :categories), %{filters: %{status: :active, id: category_info["id"]}})
      assert %{
        "action" => "categories",
        "system" => "content",
        "message" => _msg,
        "categories" => category2_info
      } = json_response(conn2, 200)

      1 = assert length(category2_info)
    end

    test "create post", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_info} = assert Category.create(@category_info)
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_post), Map.merge(@post_info, %{category_id: category_info.id}))
      assert %{
        "action" => "create_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "edit post", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_post), %{post_id: post_data.id, title: "this is a test"})

      assert %{
        "action" => "edit_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "delete post", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_post), %{post_id: post_data.id})
      assert %{
        "action" => "delete_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "destroy post", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :destroy_post), %{post_id: post_data.id})

      assert %{
        "action" => "destroy_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "post without comment", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post), %{post_id: post_data.id, status: post_data.status})

      assert %{
        "action" => "post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)

    end

    test "post with comment", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post), %{
        post_id: post_data.id,
        status: post_data.status,
        comment: %{
          page: 1,
          filters: %{status: post_data.status}
        }
      })

      assert %{
        "action" => "post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)

    end

    test "posts", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :posts), %{"page" => 1, "filters" => %{"status" => post_data.status}})
      assert %{
        "action" => "posts",
        "system" => "content",
        "message" => _msg,
        "entries" => _posts,
        "page_number" => _page_number,
        "page_size" =>  _page_size,
        "total_entries" =>  _total_entries,
        "total_pages" =>  _total_pages
      } = json_response(conn, 200)
    end

    test "like a post", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :like_post), %{"post_id" => post_data.id})

      assert %{
        "action" => "like_post",
        "system" => "content",
        "message" => _msg,
        "like_info" => _like_info
      } = json_response(conn, 200)
    end

    test "delete a like post", %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :post_like, _like_info} = assert Like.create(%{"user_id" => user_info.id, "post_id" => post_data.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_post_like), %{"post_id" => post_data.id})

      assert %{
        "action" => "delete_post_like",
        "system" => "content",
        "message" => _msg,
        "like_info" => _like_info
      } = json_response(conn, 200)
    end
  end






  describe "UnHappy | MishkaApi Content Controller ಠ╭╮ಠ" do
    test "create category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_category), Map.drop(@category_info, [:title]))

      assert %{
        "action" => "create_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 400)
    end

    test "edit category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_category), %{category_id: Ecto.UUID.generate, title: "title edit test"})

      assert %{
        "action" => "edit_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "delete category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_category), %{category_id: Ecto.UUID.generate})

      assert %{
        "action" => "delete_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "destroy category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :destroy_category), %{category_id: Ecto.UUID.generate})

      assert %{
        "action" => "destroy_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "category", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :category), %{category_id: Ecto.UUID.generate})

      assert %{
        "action" => "category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "categories", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :categories), %{})

      assert %{
        "action" => "categories",
        "system" => "content",
        "message" => _msg,
        "categories" => []
      } = json_response(conn, 200)
    end


    test "create post", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_info} = assert Category.create(@category_info)
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_post), Map.merge(%{title: "test"}, %{category_id: category_info.id}))

      assert %{
        "action" => "create_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "edit post", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_post), %{post_id: Ecto.UUID.generate, title: "test"})

      assert %{
        "action" => "edit_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "delete post", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_post), %{post_id: Ecto.UUID.generate})

      assert %{
        "action" => "delete_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "destroy post", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :destroy_post), %{post_id: Ecto.UUID.generate})

      assert %{
        "action" => "destroy_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end


    test "post without comment", %{user_info: _user_info, conn: conn, auth: auth} do

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post), %{post_id: Ecto.UUID.generate, status: :active})

      assert %{
        "action" => "post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)

    end

    test "post with comment", %{user_info: _user_info, conn: conn, auth: auth} do

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post), %{
          post_id: Ecto.UUID.generate,
          status: :active,
          comment: %{
            page: 1,
            filters: %{status: :active}
          }
        })

      assert %{
        "action" => "post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)

    end


    test "posts", %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :posts), %{"page" => 1, "filters" => %{"status" => :active}})

      assert %{
        "action" => "posts",
        "system" => "content",
        "message" => _msg,
        "entries" => [],
        "page_number" => _page_number,
        "page_size" =>  _page_size,
        "total_entries" =>  _total_entries,
        "total_pages" =>  _total_pages
      } = json_response(conn, 200)
    end


    test "like a post", %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :post_like, _like_info} = assert Like.create(%{"user_id" => user_info.id, "post_id" => post_data.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :like_post), %{"post_id" => post_data.id})

      assert %{
        "action" => "like_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "delete a like post", %{user_info: _user_info, conn: conn, auth: auth} do

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_post_like), %{"post_id" => Ecto.UUID.generate})

      assert %{
        "action" => "delete_post_like",
        "system" => "content",
        "message" => _msg,
        "errors" => _like_info
      } = json_response(conn, 404)
    end
  end
end
