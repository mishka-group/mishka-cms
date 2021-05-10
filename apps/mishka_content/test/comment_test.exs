defmodule MishkaContentTest.CommentTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaContent.General.Comment
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post
  alias MishkaContent.General.CommentLike

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

    {:ok, post_info: post_info, user_info: user_info}
  end


  describe "Happy | Comment CRUD DB (▰˘◡˘▰)" do
    test "create a commnt", context do
      {:ok, :add, :comment, _comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
    end

    test "edit a comment", context do
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      {:ok, :edit, :comment, _comment_edit_info} = assert Comment.edit(%{id: comment_info.id, description: "this is a Edit test comment we need"})
    end

    test "delete a comment", context do
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      {:ok, :delete, :comment, _comment_delete_info} = assert Comment.delete(comment_info.id)
    end

    test "show comment by id and user id", context do
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      {:ok, :get_record_by_id, :comment, _comment_id} = assert Comment.show_by_id(comment_info.id)
      {:ok, :get_record_by_field, :comment, _comment_user_id} = assert Comment.show_by_user_id(comment_info.user_id)
    end

    test "get comment with condition: {section_id, priority, status}", context do
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))

      1 = assert length(Comment.comments(conditions: {1, 20}, filters: %{priority: :none, status: :active}).entries)
      1 = assert length(Comment.comments(conditions: {1, 20}, filters: %{id: comment_info.id}).entries)
    end


    test "get comment with condition: {section_id, section, priority, status}", context do
      {:ok, :add, :comment, comment_info} = assert Comment.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))

      {:ok, :add, :user, user_info_2} = MishkaUser.User.create(
        Map.merge(@right_user_info, %{
          "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
          "username" => "usernameuniq_#{Enum.random(100000..999999)}",
          "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
        }))


      {:ok, :add, :comment, comment_2_info} = assert Comment.create(
        Map.merge(@comment_info, %{"description" => "test 2", "section_id" => context.post_info.id, "user_id" => user_info_2.id}
      ))


      CommentLike.create(%{user_id: context.user_info.id, comment_id: comment_info.id})
      CommentLike.create(%{user_id: user_info_2.id, comment_id: comment_2_info.id})
      CommentLike.create(%{user_id: user_info_2.id, comment_id: comment_info.id})

      2 = assert length Comment.comments(conditions: {1, 20}, filters: %{priority: comment_info.priority, status: :active, section: :blog_post}).entries

    end
  end

  describe "UnHappy | Comment CRUD DB ಠ╭╮ಠ" do
    test "get comment with condition: {section_id, section, priority, status}", context do
      0 = assert length(Comment.comments(conditions: {1, 20}, filters: %{user_id: context.user_info.id, section_id: Ecto.UUID.generate, priority: :none, status: :active, section: :blog_post}).entries)
    end

    test "create a commnt", context do
      {:error, :add, :comment, _comment_info} = assert Comment.create(
        %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      )
    end
  end

end
