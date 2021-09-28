defmodule MishkaContentTest.ActivityTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaContent.General.Activity
  alias MishkaContent.Blog.Category
  alias MishkaContent.Blog.Post

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

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
    {:ok, :add, :category, category_data} = Category.create(@category_info)
    post_info = Map.merge(@post_info, %{"category_id" => category_data.id})
    {:ok, :add, :post, post_info} = Post.create(post_info)
    {:ok, post_info: post_info, category_info: category_data}
  end

  @activity_info %{
    type: :section,
    section: :blog_post,
    priority: :high,
    status: :error,
    action: :add,
    extra: %{}
  }

  describe "Happy | Activity CRUD DB (▰˘◡˘▰)" do
    test "create a activity", context do
      {:ok, :add, :activity, _activity_info} = assert Activity.create(Map.merge(@activity_info, %{section_id: context.post_info.id}))
    end

    test "edit a activity", context do
      {:ok, :add, :activity, activity_info} = assert Activity.create(Map.merge(@activity_info, %{section_id: context.post_info.id}))
      {:ok, :edit, :activity, _activity_info} = assert Activity.edit(%{id: activity_info.id, section_id: nil})
    end

    test "delete a activity", context do
      {:ok, :add, :activity, activity_info} = assert Activity.create(Map.merge(@activity_info, %{section_id: context.post_info.id}))
      {:ok, :delete, :activity, _activity_info} = assert Activity.delete(activity_info.id)
    end

    test "show by id", context  do
      {:ok, :add, :activity, activity_info} = assert Activity.create(Map.merge(@activity_info, %{section_id: context.post_info.id}))
      {:ok, :get_record_by_id, :activity, _activity_info} = assert Activity.show_by_id(activity_info.id)
    end

    test "activities", context do
      {:ok, :add, :activity, _activity_info} = assert Activity.create(Map.merge(@activity_info, %{section_id: context.post_info.id}))
      1 = assert length Activity.activities(conditions: {1, 10}, filters: %{}).entries
      1 = assert length Activity.activities(conditions: {1, 10}, filters: %{type: :section, action: :add}).entries
    end
  end

  describe "UnHappy | Activity CRUD DB ಠ╭╮ಠ" do
    test "activities", _context do
      0 = assert length Activity.activities(conditions: {1, 10}, filters: %{type: :section, action: :create}).entries
    end

    test "create a activity", context do
      {:error, :add, :activity, _activity_info} = assert Activity.create(%{section_id: context.post_info.id})
    end
  end
end
