defmodule MishkaContentTest.Blog.BlogLikeTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaContent.Blog.Like
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post

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

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  setup _context do
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    {:ok, :add, :category, category_data} = Category.create(@category_info)
    post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
    {:ok, :add, :post, post_info} = Post.create(post_info)
    {:ok, post_info: post_info, user_info: user_info}
  end

  describe "Happy | Like CRUD DB (▰˘◡˘▰)" do
    test "create a like post", context do
      {:ok, :add, :post_like, _like_info} =
        assert Like.create(%{
                 "user_id" => context.user_info.id,
                 "post_id" => context.post_info.id
               })
    end

    test "show a like with id", context do
      {:ok, :add, :post_like, like_info} =
        assert Like.create(%{
                 "user_id" => context.user_info.id,
                 "post_id" => context.post_info.id
               })

      {:ok, :get_record_by_id, :post_like, _like_id} = assert Like.show_by_id(like_info.id)
    end

    test "delete a like post", context do
      {:ok, :add, :post_like, like_info} =
        assert Like.create(%{
                 "user_id" => context.user_info.id,
                 "post_id" => context.post_info.id
               })

      {:ok, :delete, :post_like, _delete_like_info} = assert Like.delete(like_info.id)
    end
  end

  describe "UnHappy | Like CRUD DB ಠ╭╮ಠ" do
    test "create a post like", context do
      {:ok, :add, :post_like, _like_info} =
        assert Like.create(%{
                 "user_id" => context.user_info.id,
                 "post_id" => context.post_info.id
               })

      {:error, :add, :post_like, _changeser} =
        assert Like.create(%{
                 "user_id" => context.user_info.id,
                 "post_id" => context.post_info.id
               })
    end
  end
end
