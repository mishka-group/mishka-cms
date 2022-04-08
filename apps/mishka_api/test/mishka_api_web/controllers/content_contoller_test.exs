defmodule MishkaApiWeb.ContentControllerTest do
  use MishkaApiWeb.ConnCase, async: true

  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post
  alias MishkaContent.Blog.Like
  alias MishkaContent.General.Comment
  alias MishkaContent.General.CommentLike
  alias MishkaContent.Blog.TagMapper
  alias MishkaContent.Blog.Tag
  alias MishkaContent.General.Bookmark
  alias MishkaContent.General.Subscription
  alias MishkaContent.Blog.BlogLink
  alias MishkaContent.General.Notif
  alias MishkaContent.Blog.Author


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

  @comment_info %{
    "description" => "test one",
    "status" => :active,
    "priority" => :none,
    "section" => :blog_post
  }

  @blog_link %{
    "short_description" => "this is a link",
    "status" => :archived,
    "type" => :inside,
    "title" => "this is link title",
    "link" => "https://test.com/test.json",
    "short_link" => "#{Ecto.UUID.generate}",
    "robots" => :IndexFollow
  }

  @notif_info %{
    status: :active,
    section: :public,
    section_id: Ecto.UUID.generate,
    title: "test for title",
    description: "this is a test of notif",
    expire_time: DateTime.utc_now(),
    type: :client,
    target: :all,
    extra: %{test: "this is a test of notif"},
  }

  alias MishkaUser.Acl.{Role, Permission, UserRole}

  setup _context do
    conn = Phoenix.ConnTest.build_conn()
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
    {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "*"})
    {:ok, :add, :user_role, _user_role_data} = assert UserRole.create(%{role_id: data.id, user_id: user_info.id})

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

    test "post without comment - alias link", %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post), %{alias_link: post_data.alias_link, status: "#{post_data.status}"})

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
        |> post(Routes.content_path(conn, :post), %{alias_link: post_data.alias_link, status: "#{post_data.status}", comment: %{page: 1, filters: %{status: "#{post_data.status}"}}})

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
        |> post(Routes.content_path(conn, :posts), %{"page" => 1, "filters" => %{"status" => "#{post_data.status}"}})
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

    test "comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :comment), %{"filters" => %{"comment_id" => comment_info.id, "status" => "active"}})

      assert %{
        "action" => "comment",
        "system" => "content",
        "message" => _msg,
        "comment_info" => _comment_info
      } = json_response(conn, 200)

      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :comment), %{
          "filters" => %{"comment_id" => comment_info.id, "status" => "active", "section" => :blog_post}})

      assert %{
        "action" => "comment",
        "system" => "content",
        "message" => _msg,
        "comment_info" => _comment_info
      } = json_response(conn1, 200)
    end

    test "comments" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, _comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))
      {:ok, :add, :comment, _comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :comments), %{"page" => 1, "filters" => %{"status" => "active"}})

        assert %{
          "action" => "comments",
          "system" => "content",
          "message" => _msg,
          "entries" => _entries,
          "page_number" => _page_number,
          "page_size" => _page_size,
          "total_entries" => _total_entries,
          "total_pages" => _total_pages
        } = json_response(conn, 200)
    end

    test "create comment" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_comment), %{"section_id" => post_data.id, description: "this is a test"})

      assert %{
        "action" => "create_comment",
        "system" => "content",
        "message" => _msg,
        "comment_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "edit comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_comment), %{"id" => comment_info.id, description: "this is a edit test"})

      assert %{
        "action" => "edit_comment",
        "system" => "content",
        "message" => _msg,
        "comment_info" => _comment_info
      } = json_response(conn, 200)
    end


    test "delete comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_comment), %{"user_id" => user_info.id, "comment_id" => comment_info.id})

      assert %{
        "action" => "delete_comment",
        "system" => "content",
        "message" => _msg,
        "comment_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "destroy comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :destroy_comment), %{"comment_id" => comment_info.id})

      assert %{
        "action" => "destroy_comment",
        "system" => "content",
        "message" => _msg,
        "comment_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "like comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :like_comment), %{"comment_id" => comment_info.id})

      assert %{
        "action" => "like_comment",
        "system" => "content",
        "message" => _msg,
        "comment_like_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "delete like comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))


      {:ok, :add, :comment_like, _comment_info} = assert CommentLike.create(
        %{"user_id" => user_info.id, "comment_id" => comment_info.id}
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_comment_like), %{"comment_id" => comment_info.id})

      assert %{
        "action" => "delete_comment_like",
        "system" => "content",
        "message" => _msg,
        "comment_like_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "create tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_tag), %{
          "title" => "tag one",
          "alias_link" => "tag1",
          "robots" => "IndexFollow"
        })

      assert %{
        "action" => "create_tag",
        "system" => "content",
        "message" => _msg,
        "tag_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "edit tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_tag), %{
          "tag_id" => tag_info.id,
          "title" => "tag one",
        })

      assert %{
        "action" => "edit_tag",
        "system" => "content",
        "message" => _msg,
        "tag_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "delete tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_tag), %{"tag_id" => tag_info.id})

      assert %{
        "action" => "delete_tag",
        "system" => "content",
        "message" => _msg,
        "tag_info" => _comment_info
      } = json_response(conn, 200)
    end

    test "add tag to post" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :add_tag_to_post), %{"tag_id" => tag_info.id, "post_id" => post_data.id})

      assert %{
        "action" => "add_tag_to_post",
        "system" => "content",
        "message" => _msg,
        "post_tag_info" => _post_tag_info
      } = json_response(conn, 200)
    end

    test "remove post tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_tag_mapper, _tag_info} = assert TagMapper.create(%{
        post_id: post_data.id,
        tag_id: tag_info.id
      })

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :remove_post_tag), %{"tag_id" => tag_info.id, "post_id" => post_data.id})

      assert %{
        "action" => "remove_post_tag",
        "system" => "content",
        "message" => _msg,
        "post_tag_info" => _post_tag_info
      } = json_response(conn, 200)
    end

    test "tags" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, _tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      {:ok, :add, :blog_tag, _tag_info} = assert Tag.create(%{
        title: "tag2",
        alias_link: "tag2",
        robots: :IndexFollow,
      })

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :tags), %{"page" => 1, "filters" => %{}})

      assert %{
        "action" => "tags",
        "system" => "content",
        "message" => _msg,
        "entries" => entries,
        "page_number" => _page_number,
        "page_size" => _page_size,
        "total_entries" => _total_entries,
        "total_pages" => _total_pages
      } = json_response(conn, 200)

      2 = assert length(entries)
    end

    test "tag posts" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_tag_mapper, _tag_info} = assert TagMapper.create(%{
        post_id: post_data.id,
        tag_id: tag_info.id
      })

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :tag_posts), %{"page" => 1, "filters" => %{"tag_id" => tag_info.id, post_status: "active"}})

      assert %{
        "action" => "tag_posts",
        "system" => "content",
        "message" => _msg,
        "entries" => entries,
        "page_number" => _page_number,
        "page_size" => _page_size,
        "total_entries" => _total_entries,
        "total_pages" => _total_pages
      } = json_response(conn, 200)

      1 = assert length entries

    end

    test "post tags" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :blog_tag, tag_info} = assert Tag.create(%{
        title: "tag1",
        alias_link: "tag1",
        meta_keywords: "tag1",
        meta_description: "tag1",
        custom_title: "tag1",
        robots: :IndexFollow,
      })

      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_tag_mapper, _tag_info} = assert TagMapper.create(%{
        post_id: post_data.id,
        tag_id: tag_info.id
      })

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post_tags), %{"post_id" => post_data.id})

        assert %{
          "action" => "post_tags",
          "system" => "content",
          "message" => _msg,
          "tags" => tags,
        } = json_response(conn, 200)

        1 = assert length(tags)
    end

    test "create bookmark" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)


      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_bookmark), %{
          "section_id" => post_data.id,
          "section" => "blog_post"
        })

        assert %{
          "action" => "create_bookmark",
          "system" => "content",
          "message" => _msg,
          "bookmark_info" => _bookmark_info,
        } = json_response(conn, 200)
    end

    test "delete bookmark" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :bookmark, _bookmark_info} = assert Bookmark.create(
        %{
          "status" => "active",
          "section" => "blog_post",
          "section_id" => post_data.id,
          "user_id" => user_info.id
        })


      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_bookmark), %{
          "section_id" => post_data.id
        })

      assert %{
        "action" => "delete_bookmark",
        "system" => "content",
        "message" => _msg,
        "bookmark_info" => _bookmark_info,
      } = json_response(conn, 200)
    end

    test "create Subscription" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)


      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_subscription), %{
          "section_id" => post_data.id,
          "section" => "blog_post"
        })

        assert %{
          "action" => "create_subscription",
          "system" => "content",
          "message" => _msg,
          "subscription_info" => _subscription_info,
        } = json_response(conn, 200)
    end

    test "delete Subscription" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      subscription_info = %{
        status: :active,
        section: :blog_post,
        extra: %{test: "this is a test of Subscription"},
      }

      {:ok, :add, :subscription, _subscription_info} = assert Subscription.create(
        Map.merge(subscription_info, %{section_id: post_data.id, user_id: user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_subscription), %{
          "section_id" => post_data.id,
          "section" => "blog_post"
        })

        assert %{
          "action" => "delete_subscription",
          "system" => "content",
          "message" => _msg,
          "subscription_info" => _subscription_info,
        } = json_response(conn, 200)
    end

    test "create blog link" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_blog_link), Map.merge(@blog_link, %{"section_id" => post_data.id}))

        assert %{
          "action" => "create_blog_link",
          "system" => "content",
          "message" => _msg,
          "blog_link_info" => _blog_link_info,
        } = json_response(conn, 200)
    end

    test "edit blog link" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_link, link_info} = assert BlogLink.create(
        Map.merge(@blog_link, %{"section_id" => post_data.id})
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_blog_link), %{"blog_link_id" => link_info.id, "status" => "active"})

        assert %{
          "action" => "edit_blog_link",
          "system" => "content",
          "message" => _msg,
          "blog_link_info" => _blog_link_info,
        } = json_response(conn, 200)
    end

    test "delete blog link" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_link, link_info} = assert BlogLink.create(
        Map.merge(@blog_link, %{"section_id" => post_data.id})
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_blog_link), %{"blog_link_id" => link_info.id})

        assert %{
          "action" => "delete_blog_link",
          "system" => "content",
          "message" => _msg,
          "blog_link_info" => _blog_link_info,
        } = json_response(conn, 200)
    end

    test "links" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_link, _link_info} = assert BlogLink.create(
        Map.merge(@blog_link, %{"section_id" => post_data.id})
      )

      {:ok, :add, :blog_link, _link_info} = assert BlogLink.create(
        Map.merge(@blog_link, %{
          "section_id" => post_data.id,
          "link" => "https://test.com/test1.json",
          "short_link" => "test-#{Ecto.UUID.generate}"
        })
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_links), %{"page" => 1, "filters" => %{}})

        assert %{
          "action" => "links",
          "system" => "content",
          "message" => _msg,
          "entries" =>  entries,
          "page_number" =>  _page_number,
          "page_size" =>  _page_size,
          "total_entries" =>  _total_entries,
          "total_pages" =>  _total_pages
        } = json_response(conn, 200)

        2 = assert length(entries)
    end

    test "Notifs client" , %{user_info: user_info, conn: conn, auth: auth} do
      user_right_info =  %{
        "full_name" => "username",
        "username" => "usernameuniq_#{Enum.random(100000..999999)}",
        "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
        "password" => "pass1Test",
        "status" => 1,
        "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
      }

      {:ok, :add, :user, user_info1} = MishkaUser.User.create(user_right_info)

      {:ok, :add, :notif, _notif_info} = assert Notif.create(Map.merge(@notif_info, %{user_id: user_info.id}))
      {:ok, :add, :notif, _notif_info} = assert Notif.create(@notif_info)
      {:ok, :add, :notif, _notif_info} = assert Notif.create(Map.merge(@notif_info, %{user_id: user_info1.id}))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_notifs), %{"page" => 1, "filters" => %{}})

        assert %{
          "action" => "notifs",
          "system" => "content",
          "message" => _msg,
          "entries" =>  entries,
          "page_number" =>  _page_number,
          "page_size" =>  _page_size,
          "total_entries" =>  _total_entries,
          "total_pages" =>  _total_pages
        } = json_response(conn, 200)


        3 = assert length(entries)

        new_conn = Phoenix.ConnTest.build_conn()
        conn1 =
          new_conn
          |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
          |> post(Routes.content_path(conn, :notifs), %{"type" => "client", "page" => 1, "filters" => %{}})

        assert %{
          "action" => "notifs",
          "system" => "content",
          "message" => _msg,
          "entries" =>  entries1,
          "page_number" =>  _page_number,
          "page_size" =>  _page_size,
          "total_entries" =>  _total_entries,
          "total_pages" =>  _total_pages
        } = json_response(conn1, 200)

        2 = assert length(entries1)
    end

    test "send notif" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :send_notif), @notif_info)

      assert %{
        "action" => "send_notif",
        "system" => "content",
        "message" => _msg,
        "notif_info" => _notif_info,
      } = json_response(conn, 200)
    end

    test "authors" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      user_right_info =  %{
        "full_name" => "username",
        "username" => "usernameuniq_#{Enum.random(100000..999999)}",
        "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
        "password" => "pass1Test",
        "status" => 1,
        "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
      }

      {:ok, :add, :user, user_info1} = MishkaUser.User.create(user_right_info)
      {:ok, :add, :blog_author, _author_info} = assert Author.create(
        %{"post_id" => post_data.id, "user_id" => user_info.id}
      )
      {:ok, :add, :blog_author, _author_info} = assert Author.create(
        %{"post_id" => post_data.id, "user_id" => user_info1.id}
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :authors), %{"post_id" => post_data.id})

      assert %{
        "action" => "authors",
        "system" => "content",
        "message" => _msg,
        "authors" => authors,
      } = json_response(conn, 200)

      2 = assert length(authors)
    end

    test "create author" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_author), %{"post_id" => post_data.id, "user_id" => user_info.id})

      assert %{
        "action" => "create_author",
        "system" => "content",
        "message" => _msg,
        "author_info" => _authors,
      } = json_response(conn, 200)

    end

    test "delete author" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :add, :blog_author, _author_info} = assert Author.create(
        %{"post_id" => post_data.id, "user_id" => user_info.id}
      )

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_author), %{"post_id" => post_data.id, "user_id" => user_info.id})

      assert %{
        "action" => "delete_author",
        "system" => "content",
        "message" => _msg,
        "author_info" => _authors,
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
        |> post(Routes.content_path(conn, :post), %{alias_link: Ecto.UUID.generate, status: "active"})

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
          alias_link: Ecto.UUID.generate,
          status: "active",
          comment: %{
            page: 1,
            filters: %{status: "active"}
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
        |> post(Routes.content_path(conn, :posts), %{"page" => 1, "filters" => %{"status" => "active"}})

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

    test "comment" , %{user_info: user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_data.id, "user_id" => user_info.id}
      ))

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :comment), %{"filters" => %{"comment_id" => "Ecto.UUID.generate", "status" => "active"}})

      assert %{
        "action" => "comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)

      new_conn = Phoenix.ConnTest.build_conn()
      conn1 =
        new_conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_comment), %{
          "filters" => %{"id" => comment_info.id, "status" => "inactive", "section" => "blog_post"}})

      assert %{
        "action" => "comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _comment_info
      } = json_response(conn1, 404)
    end

    test "comments" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_comments), %{"page" => 1, "filters" =>
        %{"some_none" => 12, "section" => :blog_post, "status" => "inactive"}})

        assert %{
          "action" => "comments",
          "system" => "content",
          "message" => _msg,
          "entries" => entries,
          "page_number" => _page_number,
          "page_size" => _page_size,
          "total_entries" => _total_entries,
          "total_pages" => _total_pages
        } = json_response(conn, 200)

        0 = assert length(entries)
    end

    test "create comment" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_comment), %{"section_id" => "test", description: "this is a test"})

      assert %{
        "action" => "create_comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "edit comment" , %{user_info: _user_info, conn: conn, auth: auth} do

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_comment), %{"id" => "bad_id_test", description: "this is a edit test"})

      assert %{
        "action" => "edit_comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _comment_info
      } = json_response(conn, 404)
    end

    test "delete comment" , %{user_info: user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_comment), %{"user_id" => user_info.id, "comment_id" => "bad_id_test"})

      assert %{
        "action" => "delete_comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "destroy comment" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :destroy_comment), %{"comment_id" => "bad_id_test"})

      assert %{
        "action" => "destroy_comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "like comment" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :like_comment), %{"comment_id" => "bad_id_test"})

      assert %{
        "action" => "like_comment",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "delete like comment" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_comment_like), %{"comment_id" => "bad_id_test"})

      assert %{
        "action" => "delete_comment_like",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "create tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_tag), %{
          "title" => "",
          "alias_link" => "tag1",
          "robots" => "IndexFollow"
        })

      assert %{
        "action" => "create_tag",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "edit tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_tag), %{
          "tag_id" => "bad_id_test",
          "title" => "tag one",
        })

      assert %{
        "action" => "edit_tag",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "delete tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_tag), %{"tag_id" => "bad_id_test"})

      assert %{
        "action" => "delete_tag",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "add tag to post" , %{user_info: _user_info, conn: conn, auth: auth} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :add_tag_to_post), %{"tag_id" => "bad_id_test", "post_id" => post_data.id})

      assert %{
        "action" => "add_tag_to_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "remove post tag" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :remove_post_tag), %{"tag_id" => "bad_id_test", "post_id" => "bad_id_test"})

      assert %{
        "action" => "remove_post_tag",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "tags" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :tags), %{"page" => 1, "filters" => %{}})

      assert %{
        "action" => "tags",
        "system" => "content",
        "message" => _msg,
        "entries" => entries,
        "page_number" => _page_number,
        "page_size" => _page_size,
        "total_entries" => _total_entries,
        "total_pages" => _total_pages
      } = json_response(conn, 200)

      0 = assert length(entries)
    end

    test "tag posts" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_tag_posts), %{"page" => 1, "filters" => %{"tag_id" => "bad_id_test"}})

      assert %{
        "action" => "tag_posts",
        "system" => "content",
        "message" => _msg,
        "entries" => entries,
        "page_number" => _page_number,
        "page_size" => _page_size,
        "total_entries" => _total_entries,
        "total_pages" => _total_pages
      } = json_response(conn, 200)

      0 = assert length entries

    end

    test "post tags" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :post_tags), %{"post_id" => "bad_id_test"})

        assert %{
          "action" => "post_tags",
          "system" => "content",
          "message" => _msg,
          "tags" => tags,
        } = json_response(conn, 200)

        0 = assert length(tags)
    end

    test "create bookmark" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_bookmark), %{
          "section_id" => "bad_id_test",
          "section" => "blog_post"
        })

        assert %{
          "action" => "create_bookmark",
          "system" => "content",
          "message" => _msg,
          "errors" => _errors,
        } = json_response(conn, 400)
    end

    test "delete bookmark" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_bookmark), %{
          "section_id" => "bad_id_test"
        })

      assert %{
        "action" => "delete_bookmark",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors,
      } = json_response(conn, 404)
    end

    test "create Subscription" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_subscription), %{
          "section_id" => "bad_id_test",
          "section" => "blog_post"
        })

        assert %{
          "action" => "create_subscription",
          "system" => "content",
          "message" => _msg,
          "errors" => _errors,
        } = json_response(conn, 400)
    end

    test "delete Subscription" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_subscription), %{
          "section_id" => "bad_id_test",
          "section" => "blog_post"
        })

        assert %{
          "action" => "delete_subscription",
          "system" => "content",
          "message" => _msg,
          "errors" => _errors,
        } = json_response(conn, 404)
    end

    test "create blog link" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_blog_link), %{"section_id" => "bad_id_test"})

        assert %{
          "action" => "create_blog_link",
          "system" => "content",
          "message" => _msg,
          "errors" => _errors,
        } = json_response(conn, 400)
    end

    test "edit blog link" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :edit_blog_link), %{"blog_link_id" => "bad_id_test", "status" => "active"})

        assert %{
          "action" => "edit_blog_link",
          "system" => "content",
          "message" => _msg,
          "errors" => _errors,
        } = json_response(conn, 404)
    end

    test "delete blog link" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_blog_link), %{"blog_link_id" => "bad_id_test"})

        assert %{
          "action" => "delete_blog_link",
          "system" => "content",
          "message" => _msg,
          "errors" => _errors,
        } = json_response(conn, 404)
    end

    test "links" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_links), %{"page" => 1, "filters" => %{}})

        assert %{
          "action" => "links",
          "system" => "content",
          "message" => _msg,
          "entries" =>  entries,
          "page_number" =>  _page_number,
          "page_size" =>  _page_size,
          "total_entries" =>  _total_entries,
          "total_pages" =>  _total_pages
        } = json_response(conn, 200)

        0 = assert length(entries)
    end

    test "Notifs client" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :editor_notifs), %{"page" => 1, "filters" => %{}})

        assert %{
          "action" => "notifs",
          "system" => "content",
          "message" => _msg,
          "entries" =>  entries,
          "page_number" =>  _page_number,
          "page_size" =>  _page_size,
          "total_entries" =>  _total_entries,
          "total_pages" =>  _total_pages
        } = json_response(conn, 200)


        0 = assert length(entries)

        new_conn = Phoenix.ConnTest.build_conn()
        conn1 =
          new_conn
          |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
          |> post(Routes.content_path(conn, :notifs), %{"type" => "client", "page" => 1, "filters" => %{}})

        assert %{
          "action" => "notifs",
          "system" => "content",
          "message" => _msg,
          "entries" =>  entries1,
          "page_number" =>  _page_number,
          "page_size" =>  _page_size,
          "total_entries" =>  _total_entries,
          "total_pages" =>  _total_pages
        } = json_response(conn1, 200)

        0 = assert length(entries1)
    end

    test "send notif" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :send_notif), %{})

      assert %{
        "action" => "send_notif",
        "system" => "content",
        "message" => _msg,
        "errors" => _notif_info,
      } = json_response(conn, 400)
    end

    test "authors" , %{user_info: _user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :authors), %{"post_id" => "bad_id_test"})

      assert %{
        "action" => "authors",
        "system" => "content",
        "message" => _msg,
        "authors" => authors,
      } = json_response(conn, 200)

      0 = assert length(authors)
    end

    test "create author" , %{user_info: user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :create_author), %{"post_id" => "bad_id_test", "user_id" => user_info.id})

      assert %{
        "action" => "create_author",
        "system" => "content",
        "message" => _msg,
        "errors" => _authors,
      } = json_response(conn, 400)

    end

    test "delete author" , %{user_info: user_info, conn: conn, auth: auth} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{auth["access_token"]}")
        |> post(Routes.content_path(conn, :delete_author), %{"post_id" => "bad_id_test", "user_id" => user_info.id})

      assert %{
        "action" => "delete_author",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors,
      } = json_response(conn, 404)

    end
  end
end
