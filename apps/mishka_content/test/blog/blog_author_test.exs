defmodule MishkaContentTest.Blog.BlogAuthorTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaContent.Blog.Author
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

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

  setup _context do
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    {:ok, :add, :category, category_data} = Category.create(@category_info)
    post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
    {:ok, :add, :post, post_info} = Post.create(post_info)

    {:ok, post_info: post_info, user_info: user_info}
  end

  describe "Happy | Author CRUD DB (▰˘◡˘▰)" do
    test "create an author for a post", context do
      {:ok, :add, :blog_author, _author_info} = assert Author.create(
        %{
          "post_id" => context.post_info.id,
          "user_id" => context.user_info.id
        }
      )
    end

    test "edit an author for a post", context do
      {:ok, :add, :blog_author, author_info} = assert Author.create(
        %{
          "post_id" => context.post_info.id,
          "user_id" => context.user_info.id
        }
      )

      new_user = Map.merge(@right_user_info, %{
        "username" => "usernameuniq_#{Enum.random(100000..999999)}",
        "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
        "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
      })

      {:ok, :add, :user, user_info} = MishkaUser.User.create(new_user)
      {:ok, :edit, :blog_author, _author_info} = assert Author.edit(
        %{
          id: author_info.id,
          post_id: context.post_info.id,
          user_id: user_info.id
        }
      )
    end

    test "delete an auther for a post", context do
      {:ok, :add, :blog_author, author_info} = assert Author.create(
        %{
          "post_id" => context.post_info.id,
          "user_id" => context.user_info.id
        }
      )
      {:ok, :delete, :blog_author, _author_info} = assert Author.delete(author_info.id)
    end

    test "show by id", context do
      {:ok, :add, :blog_author, author_info} = assert Author.create(
        %{
          "post_id" => context.post_info.id,
          "user_id" => context.user_info.id
        }
      )
      {:ok, :get_record_by_id, :blog_author, _author_info} = assert Author.show_by_id(author_info.id)
    end

    test "show Authors of a post", context do
      {:ok, :add, :blog_author, _author_info} = assert Author.create(
        %{
          "post_id" => context.post_info.id,
          "user_id" => context.user_info.id
        }
      )

      new_user = Map.merge(@right_user_info, %{
        "username" => "usernameuniq_#{Enum.random(100000..999999)}",
        "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
        "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
      })

      {:ok, :add, :user, user_info} = MishkaUser.User.create(new_user)
      {:ok, :add, :blog_author, _author_info} = assert Author.create(
        %{
          "post_id" => context.post_info.id,
          "user_id" => user_info.id
        }
      )

      2 = assert length(Post.post(context.post_info.alias_link, context.post_info.status).blog_authors)
    end
  end

  describe "UnHappy | Author CRUD DB ಠ╭╮ಠ" do
    test "show Authors of a post", context do
      [] = assert Post.post(context.post_info.alias_link, context.post_info.status).blog_authors
    end

    test "create an author for a post", context do
      {:error, :add, :blog_author, _author_info} = assert Author.create(
        %{
          "post_id" => Ecto.UUID.generate,
          "user_id" => context.user_info.id
        }
      )
    end
  end
end
