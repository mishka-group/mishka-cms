defmodule MishkaContentTest.CommentLikeTest do

  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaContent.General.Comment
  alias MishkaContent.General.CommentLike
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post


  @right_user_info %{
    "full_name" => "username",
    "username" => "usernameuniq_#{Enum.random(100000..999999)}",
    "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
    "password" => "pass1Test",
    "status" => 1,
    "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
  }


  @category_info %{
    "title" => "Test Category",
    "short_description" => "Test category description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test category description",
    "alias_link" => "test-category-test",
  }

  @post_info %{
    "title" => "Test Post",
    "short_description" => "Test post description",
    "main_image" => "https://test.com/png.png",
    "description" => "Test post description",
    "status" => :active,
    "priority" => :none,
    "alias_link" => "test-post-test",
    "robots" => :IndexFollow,
  }

  @comment_info %{
    "description" => "test one",
    "status" => :active,
    "priority" => :none,
    "section" => :blog_post
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
    {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => post_info.id, "user_id" => user_info.id}
      ))
    {:ok, post_info: post_info, user_info: user_info, comment_info: comment_info}
  end


  describe "Happy | CommentLike CRUD DB (▰˘◡˘▰)" do
    test "create a comment like", context do
      {:ok, :add, :comment_like, _comment_info} = assert CommentLike.create(
        %{"user_id" => context.user_info.id, "comment_id" => context.comment_info.id}
      )
    end

    test "edit a comment like", context do
      {:ok, :add, :comment_like, comment_info} = assert CommentLike.create(
        %{"user_id" => context.user_info.id, "comment_id" => context.comment_info.id}
      )
      {:ok, :edit, :comment_like, _comment_edit_info} = assert CommentLike.edit(
        %{id: comment_info.id, user_id: context.user_info.id, comment_id: context.comment_info.id}
      )
    end

    test "delete a comment like", context do
      {:ok, :add, :comment_like, comment_like_info} = assert CommentLike.create(
        %{"user_id" => context.user_info.id, "comment_id" => context.comment_info.id}
      )
      {:ok, :delete, :comment_like, _comment_edit_info} = assert CommentLike.delete(comment_like_info.id)
    end

    test "show by id", context do
      {:ok, :add, :comment_like, comment_like_info} = assert CommentLike.create(
        %{"user_id" => context.user_info.id, "comment_id" => context.comment_info.id}
      )
      {:ok, :get_record_by_id, :comment_like, _comment_like_id} = assert CommentLike.show_by_id(comment_like_info.id)
    end

    test "likes", context do

      {:ok, :add, :user, user_info_2} = MishkaUser.User.create(
        Map.merge(@right_user_info, %{
          "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
          "username" => "usernameuniq_#{Enum.random(100000..999999)}",
          "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
      }))

      {:ok, :add, :comment, comment_2_info} = assert Comment.create(
        Map.merge(@comment_info, %{"description" => "test 2", "section_id" => context.post_info.id, "user_id" => user_info_2.id}
      ))

      {:ok, :add, :comment_like, _comment_like_info} = assert CommentLike.create(%{user_id: context.user_info.id, comment_id: context.comment_info.id})
      {:ok, :add, :comment_like, _comment_like_info} = assert CommentLike.create(%{user_id: user_info_2.id, comment_id: context.comment_info.id})
      {:ok, :add, :comment_like, _comment_like_info} = assert CommentLike.create(%{user_id: user_info_2.id, comment_id: comment_2_info.id})

    query = Comment.comments(conditions: {1, 20}, filters: %{id: context.comment_info.id, section_id: context.comment_info.section_id, section: :blog_post, priority: context.comment_info.priority, status: context.comment_info.status}, user_id: nil).entries
    true = assert Enum.any?(query, fn x -> x.like_count == 2 end)
    end
  end

  describe "UnHappy | CommentLike CRUD DB ಠ╭╮ಠ" do
    test "likes", _context do
      [] = assert Comment.comments(conditions: {1, 20}, filters: %{section_id: Ecto.UUID.generate, section: :blog_post, priority: :none,}, user_id: nil).entries
    end

    test "create a comment like", context do
      {:error, :add, :comment_like, _comment_info} = assert CommentLike.create(
        %{"user_id" => context.user_info.id}
      )
    end
  end
end
