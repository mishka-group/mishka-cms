defmodule MishkaApiWeb.ContentControllerTest do
  use MishkaApiWeb.ConnCase, async: true

  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post
  alias MishkaContent.Blog.Like
  alias MishkaContent.General.Comment
  alias MishkaContent.General.CommentLike
  alias MishkaContent.Blog.TagMapper
  alias MishkaContent.Blog.Tag

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
        |> post(Routes.content_path(conn, :tag_posts), %{"page" => 1, "filters" => %{"tag_id" => tag_info.id}})

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
