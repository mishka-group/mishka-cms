defmodule MishkaApiWeb.ContentControllerTest do
  use MishkaApiWeb.ConnCase, async: true

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
  end


  describe "UnHappy | MishkaApi Content Controller ಠ╭╮ಠ" do
    test "create category", %{conn: conn} do
      conn = post(conn, Routes.content_path(conn, :create_category), Map.drop(@category_info, [:title]))

      assert %{
        "action" => "create_category",
        "system" => "content",
        "message" => _msg,
        "errors" => _category_info
      } = json_response(conn, 401)
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
        "error" => _category_info
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
  end
end
