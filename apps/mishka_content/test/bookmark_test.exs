defmodule MishkaContentTest.BookmarkTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaContent.General.Bookmark

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

  @bookmark_info %{
    status: :active,
    section: :blog_post,
    section_id: Ecto.UUID.generate,
    extra: %{test: "this is a test of bookmark"},
  }


  setup _context do
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    {:ok, user_info: user_info}
  end

  describe "Happy | Bookmark CRUD DB (▰˘◡˘▰)" do
    test "create a bookmark", context do
      {:ok, :add, :bookmark, _bookmark_info} = assert Bookmark.create(
        Map.merge(@bookmark_info, %{user_id: context.user_info.id}
      ))
    end

    test "edit a bookmark", context do
      {:ok, :add, :bookmark, bookmark_info} = assert Bookmark.create(
        Map.merge(@bookmark_info, %{user_id: context.user_info.id}
      ))

      {:ok, :edit, :bookmark, _bookmark_info} = assert Bookmark.edit(
        Map.merge(@bookmark_info, %{id: bookmark_info.id, extra: %{test: "test bookmark 2"}}
      ))
    end

    test "delete a bookmark", context do
      {:ok, :add, :bookmark, bookmark_info} = assert Bookmark.create(
        Map.merge(@bookmark_info, %{user_id: context.user_info.id}
      ))

      {:ok, :delete, :bookmark, _bookmark_info} = assert Bookmark.delete(bookmark_info.id)
    end

    test "show by id", context do
      {:ok, :add, :bookmark, bookmark_info} = assert Bookmark.create(
        Map.merge(@bookmark_info, %{user_id: context.user_info.id}
      ))
      {:ok, :get_record_by_id, :bookmark, _bookmark_info} = assert Bookmark.show_by_id(bookmark_info.id)
    end

    test "show user Bookmark", context do
      {:ok, :add, :bookmark, bookmark_info} = assert Bookmark.create(
        Map.merge(@bookmark_info, %{user_id: context.user_info.id}
      ))

      1 = assert length Bookmark.bookmarks(bookmark_info.user_id, condition: %{paginate: {1, 10}}).entries
      1 = assert length Bookmark.bookmarks(condition: %{paginate: {1, 10}}).entries
    end
  end

  describe "UnHappy | Bookmark CRUD DB ಠ╭╮ಠ" do
    test "show user Bookmark", context do
      0 = assert length Bookmark.bookmarks(context.user_info.id, condition: %{paginate: {1, 10}}).entries
      0 = assert length Bookmark.bookmarks(condition: %{paginate: {1, 10}}).entries
    end

    test "create a bookmark", context do
      {:error, :add, :bookmark, _bookmark_info} = assert Bookmark.create(
        %{user_id: context.user_info.id}
      )
    end
  end
end
