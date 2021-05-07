defmodule MishkaContentTest.CommentTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaContent.General.Comments
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
      {:ok, :add, :comment, _comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
    end

    test "edit a comment", context do
      {:ok, :add, :comment, comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      {:ok, :edit, :comment, _comment_edit_info} = assert Comments.edit(%{id: comment_info.id, description: "this is a Edit test comment we need"})
    end

    test "delete a comment", context do
      {:ok, :add, :comment, comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      {:ok, :delete, :comment, _comment_delete_info} = assert Comments.delete(comment_info.id)
    end

    test "show comment by id and user id", context do
      {:ok, :add, :comment, comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      {:ok, :get_record_by_id, :comment, _comment_id} = assert Comments.show_by_id(comment_info.id)
      {:ok, :get_record_by_field, :comment, _comment_user_id} = assert Comments.show_by_user_id(comment_info.user_id)
    end

    test "get comment with condition: {section_id, priority, status}", context do
      {:ok, :add, :comment, comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      1 = assert length(
        Comments.comments(comment_info.section_id, condition: %{priority: :none, paginate: {1, 20}, status: :active}).entries
      )
      1 = assert length(
        Comments.comments(comment_info.section_id, condition: %{priority: :none, paginate: {1, 20}}).entries
      )
    end

    test "get comment with condition: {priority, status}", context do
      {:ok, :add, :comment, _comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))
      1 = assert length(
        Comments.comments(condition: %{priority: :none, paginate: {1, 20}, status: :active}).entries
      )
      1 = assert length(
        Comments.comments(condition: %{priority: :none, paginate: {1, 20}}).entries
      )

      1 = assert length(
        Comments.comments(condition: %{status: :active, paginate: {1, 20}}).entries
      )

      1 = assert length(
        Comments.comments(condition: %{paginate: {1, 20}}).entries
      )
    end

    test "get comment with condition: {section_id, section, priority, status}", context do
      {:ok, :add, :comment, comment_info} = assert Comments.create(
        Map.merge(@comment_info, %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      ))

      {:ok, :add, :user, user_info_2} = MishkaUser.User.create(
        Map.merge(@right_user_info, %{
          "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
          "username" => "usernameuniq_#{Enum.random(100000..999999)}",
          "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
        }))


      {:ok, :add, :comment, comment_2_info} = assert Comments.create(
        Map.merge(@comment_info, %{"description" => "test 2", "section_id" => context.post_info.id, "user_id" => user_info_2.id}
      ))


      CommentLike.create(%{user_id: context.user_info.id, comment_id: comment_info.id})
      CommentLike.create(%{user_id: user_info_2.id, comment_id: comment_2_info.id})
      CommentLike.create(%{user_id: user_info_2.id, comment_id: comment_info.id})



      2 = assert length(Comments.comments(comment_info.section_id,
        condition: %{
          section: :blog_post, priority: comment_info.priority, paginate: {1, 20}, status: comment_info.status
        }
      ).entries)


      2 = assert length(Comments.comments(comment_info.section_id,
        condition: %{
          section: :blog_post, paginate: {1, 20}, status: comment_info.status
        }
      ).entries)

      2 = assert length(Comments.comments(comment_info.section_id,
        condition: %{
          section: :blog_post, paginate: {1, 20}
        }
      ).entries)
    end
  end

  describe "UnHappy | Comment CRUD DB ಠ╭╮ಠ" do
    test "get comment with condition: {section_id, section, priority, status}", context do
      0 = assert length(Comments.comments(context.user_info.id,
        condition: %{
          section: :blog_post, paginate: {1, 20}}).entries)

      0 = assert length(Comments.comments(Ecto.UUID.generate,
        condition: %{
          section: :blog_post, paginate: {1, 20}, status: :active}).entries)

      0 = assert length(Comments.comments(Ecto.UUID.generate,
      condition: %{
        section: :blog_post, priority: :none, paginate: {1, 20}, status: :active
      }).entries)
    end

    test "create a commnt", context do
      {:error, :add, :comment, _comment_info} = assert Comments.create(
        %{"section_id" => context.post_info.id, "user_id" => context.user_info.id}
      )
    end
  end

end
