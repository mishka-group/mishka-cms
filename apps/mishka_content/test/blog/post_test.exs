defmodule MishkaContentTest.Blog.PostTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post
  alias MishkaContent.Blog.Like

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @category_info %{
    "title" => "Test Category",
    "short_description" => "Test category description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test category description",
    "alias_link" => "test-category-test"
  }

  @post_info %{
    "title" => "Test Post",
    "short_description" => "Test post description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test post description",
    "status" => :active,
    "priority" => :none,
    "alias_link" => "test-post-test",
    "robots" => :IndexFollow
  }

  @right_user_info %{
    "full_name" => "username",
    "username" => "usernameuniq_#{Enum.random(100_000..999_999)}",
    "email" => "user_name_#{Enum.random(100_000..999_999)}@gmail.com",
    "password" => "pass1Test",
    "status" => 1,
    "unconfirmed_email" => "user_name_#{Enum.random(100_000..999_999)}@gmail.com"
  }

  describe "Happy | Blog Post CRUD DB (▰˘◡˘▰)" do
    test "create a post" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
      {:ok, :add, :post, _post_data} = assert Post.create(post_info)
    end

    test "edit a post" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :edit, :post, _edit_data} =
        assert Post.edit(Map.merge(%{title: "Test 123 test Test"}, %{id: post_data.id}))
    end

    test "delete a post" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :delete, :post, _struct} = assert Post.delete(post_data.id)
    end

    test "show by id" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)
      {:ok, :get_record_by_id, :post, _record_info} = assert Post.show_by_id(post_data.id)
    end

    test "show by alias link" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)
      post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
      {:ok, :add, :post, post_data} = assert Post.create(post_info)

      {:ok, :get_record_by_field, :post, _record_info} =
        assert Post.show_by_alias_link(post_data.alias_link)
    end

    test "posts of a cteagory" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)

      {:ok, :add, :post, _post_data} =
        assert Post.create(Map.merge(@post_info, %{"category_id" => category_data.id}))

      {:ok, :add, :post, _post_data} =
        assert Post.create(
                 Map.merge(@post_info, %{
                   "category_id" => category_data.id,
                   "alias_link" => "test-two-of-post"
                 })
               )

      2 =
        assert length(
                 Category.posts(
                   conditions: {:extra_data, 1, 20},
                   filters: %{status: :active, id: category_data.id}
                 ).entries
               )
    end

    test "posts and post priority" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)

      {:ok, :add, :post, _post_data} =
        assert Post.create(Map.merge(@post_info, %{"category_id" => category_data.id}))

      1 =
        assert length(
                 Post.posts(conditions: {1, 20}, filters: %{status: :active}, user_id: nil).entries
               )

      1 =
        assert length(
                 Post.posts(
                   conditions: {1, 20},
                   filters: %{priority: :none, status: :active, category_id: category_data.id},
                   user_id: nil
                 ).entries
               )

      1 = assert length(Post.posts(conditions: {1, 20}, filters: %{}, user_id: nil).entries)
    end

    test "show post with counted like" do
      {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)

      {:ok, :add, :post, post_data} =
        assert Post.create(Map.merge(@post_info, %{"category_id" => category_data.id}))

      {:ok, :add, :post_like, _like_info} =
        assert Like.create(%{
                 "user_id" => user_info.id,
                 "post_id" => post_data.id
               })

      {:ok, :add, :blog_author, _author_info} =
        assert MishkaContent.Blog.Author.create(%{
                 "post_id" => post_data.id,
                 "user_id" => user_info.id
               })

      1 = assert Like.count_post_likes(post_data.id, user_info.id).count
    end
  end

  describe "UnHappy | Blog Post CRUD DB ಠ╭╮ಠ" do
    test "create a post" do
      {:ok, :add, :category, category_data} = assert Category.create(@category_info)

      post_not_right =
        Map.merge(@post_info, %{"category_id" => category_data.id})
        |> Map.drop(["title"])

      {:error, :add, :category, _changeset} = assert Category.create(post_not_right)
    end

    test "posts of a cteagory" do
      {:ok, :add, :category, _category_data} = assert Category.create(@category_info)
      0 = assert length(Category.posts(conditions: {:extra_data, 1, 20}, filters: %{}).entries)
    end
  end
end
