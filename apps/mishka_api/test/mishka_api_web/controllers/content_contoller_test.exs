defmodule MishkaApiWeb.ContentControllerTest do
  use MishkaApiWeb.ConnCase, async: true

  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post


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

  describe "Happy | MishkaApi Content Controller (▰˘◡˘▰)" do
    test "create category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @category_info)

      assert %{
        "action" => "create_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn, 200)
    end

    test "edit category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      conn1 = post(conn, Routes.content_path(conn, :edit_category), %{category_id: category_info["id"], title: "title edit test"})
      assert %{
        "action" => "edit_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)
    end

    test "delete category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      conn1 = post(conn, Routes.content_path(conn, :delete_category), %{category_id: category_info["id"]})
      assert %{
        "action" => "delete_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)
    end

    test "destroy category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      conn1 = post(conn, Routes.content_path(conn, :destroy_category), %{category_id: category_info["id"]})
      assert %{
        "action" => "destroy_category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)
    end

    test "category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)


      conn1 = post(conn, Routes.content_path(conn, :category), %{category_id: category_info["id"]})
      assert %{
        "action" => "category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn1, 200)

      conn2 = post(conn, Routes.content_path(conn, :category), %{alias_link: category_info["alias_link"]})
      assert %{
        "action" => "category",
        "system" => "content",
        "message" => _msg,
        "category_info" => _category_info
      } = json_response(conn2, 200)
    end

    test "categories", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), @category_info)

      %{
        "action" => "create_category", "system" => "content","message" => _msg,
        "category_info" => category_info
      } = json_response(conn, 200)

      conn1 = post(conn, Routes.content_path(conn, :categories), %{})
      assert %{
        "action" => "categories",
        "system" => "content",
        "message" => _msg,
        "categories" => _category_info
      } = json_response(conn1, 200)

      conn2 = post(conn, Routes.content_path(conn, :categories), %{filters: %{status: :active, id: category_info["id"]}})
      assert %{
        "action" => "categories",
        "system" => "content",
        "message" => _msg,
        "categories" => category2_info
      } = json_response(conn2, 200)

      1 = assert length(category2_info)
    end

    test "create post", %{conn: conn} do
      {:ok, :add, :category, category_info} = assert Category.create(@category_info)
      conn = post(conn, Routes.content_path(conn, :create_post), Map.merge(@post_info, %{category_id: category_info.id}))
      assert %{
        "action" => "create_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "edit post", %{conn: conn} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      conn = post(conn, Routes.content_path(conn, :edit_post), %{post_id: post_data.id, title: "this is a test"})
      assert %{
        "action" => "edit_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "delete post", %{conn: conn} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      conn = post(conn, Routes.content_path(conn, :delete_post), %{post_id: post_data.id})
      assert %{
        "action" => "delete_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "destroy post", %{conn: conn} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      conn = post(conn, Routes.content_path(conn, :destroy_post), %{post_id: post_data.id})
      assert %{
        "action" => "destroy_post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)
    end

    test "post without comment", %{conn: conn} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn = post(conn, Routes.content_path(conn, :post), %{post_id: post_data.id, status: post_data.status})

      assert %{
        "action" => "post",
        "system" => "content",
        "message" => _msg,
        "post_info" => _post_info
      } = json_response(conn, 200)

    end

    test "post with comment", %{conn: conn} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn = post(conn, Routes.content_path(conn, :post), %{
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

    test "posts", %{conn: conn} do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{category_id: category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      conn = post(conn, Routes.content_path(conn, :posts), %{"page" => 1, "filters" => %{"status" => post_data.status}})
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
  end


  describe "UnHappy | MishkaApi Content Controller ಠ╭╮ಠ" do
    test "create category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), Map.drop(@category_info, [:title]))

      assert %{
        "action" => "create_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 400)
    end

    test "edit category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :edit_category), %{category_id: Ecto.UUID.generate, title: "title edit test"})
      assert %{
        "action" => "edit_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "delete category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :delete_category), %{category_id: Ecto.UUID.generate})
      assert %{
        "action" => "delete_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "destroy category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :destroy_category), %{category_id: Ecto.UUID.generate})
      assert %{
        "action" => "destroy_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :category), %{category_id: Ecto.UUID.generate})
      assert %{
        "action" => "category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 404)
    end

    test "categories", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :categories), %{})
      assert %{
        "action" => "categories",
        "system" => "content",
        "message" => _msg,
        "categories" => []
      } = json_response(conn, 200)
    end


    test "create post", %{conn: conn} do
      {:ok, :add, :category, category_info} = assert Category.create(@category_info)
      conn = post(conn, Routes.content_path(conn, :create_post), Map.merge(%{title: "test"}, %{category_id: category_info.id}))
      assert %{
        "action" => "create_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 400)
    end

    test "edit post", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :edit_post), %{post_id: Ecto.UUID.generate, title: "test"})
      assert %{
        "action" => "edit_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "delete post", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :delete_post), %{post_id: Ecto.UUID.generate})
      assert %{
        "action" => "delete_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end

    test "destroy post", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :destroy_post), %{post_id: Ecto.UUID.generate})
      assert %{
        "action" => "destroy_post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)
    end


    test "post without comment", %{conn: conn} do

      conn = post(conn, Routes.content_path(conn, :post), %{post_id: Ecto.UUID.generate, status: :active})

      assert %{
        "action" => "post",
        "system" => "content",
        "message" => _msg,
        "errors" => _errors
      } = json_response(conn, 404)

    end

    test "post with comment", %{conn: conn} do

      conn = post(conn, Routes.content_path(conn, :post), %{
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


    test "posts", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :posts), %{"page" => 1, "filters" => %{"status" => :active}})
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

  end
end
