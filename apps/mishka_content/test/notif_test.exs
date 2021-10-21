defmodule MishkaContentTest.NotifTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaContent.General.Notif

  @right_user_info %{
    "full_name" => "username",
    "username" => "usernameuniq_#{Enum.random(100000..999999)}",
    "email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
    "password" => "pass1Test",
    "status" => 1,
    "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
  }

  @notif_info %{
    status: :active,
    section: :public,
    section_id: Ecto.UUID.generate,
    title: "this is a test of notif",
    expire_time: DateTime.utc_now(),
    type: :client,
    target: :all,
    description: "<p> this is a test more than 10</p>",
    extra: %{test: "this is a test of notif"},
  }


  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  setup _context do
    {:ok, :add, :user, user_info} = MishkaUser.User.create(@right_user_info)
    {:ok, user_info: user_info}
  end

  describe "Happy | Notif CRUD DB (▰˘◡˘▰)" do
    test "create a notif", context do
      {:ok, :add, :notif, _notif_info} = assert Notif.create(
        Map.merge(@notif_info, %{user_id: context.user_info.id}
      ))
    end

    test "edit a notif", context do
      {:ok, :add, :notif, notif_info} = assert Notif.create(
        Map.merge(@notif_info, %{user_id: context.user_info.id}
      ))

      {:ok, :edit, :notif, _notif_info} = assert Notif.edit(
        Map.merge(@notif_info, %{id: notif_info.id, title: "test 2 of this", user_id: context.user_info.id}
      ))
    end

    test "delete a notif", context do
      {:ok, :add, :notif, notif_info} = assert Notif.create(
        Map.merge(@notif_info, %{user_id: context.user_info.id}
      ))

      {:ok, :delete, :notif, _notif_info} = assert Notif.delete(notif_info.id)
    end

    test "show by id", context do
      {:ok, :add, :notif, notif_info} = assert Notif.create(
        Map.merge(@notif_info, %{user_id: context.user_info.id}
      ))
      {:ok, :get_record_by_id, :notif, _notif_info} = assert Notif.show_by_id(notif_info.id)
    end

    test "show user notifs", context do
      {:ok, :add, :notif, notif_info} = assert Notif.create(
        Map.merge(@notif_info, %{user_id: context.user_info.id}
      ))

      1 = assert length Notif.notifs(conditions: {1, 10}, filters: %{user_id: notif_info.user_id}).entries
      1 = assert length Notif.notifs(conditions: {1, 10}, filters: %{}).entries
    end
  end

  describe "UnHappy | Notif CRUD DB ಠ╭╮ಠ" do
    test "show user notifs", _context do
      0 = assert length Notif.notifs(conditions: {1, 10}, filters: %{user_id: Ecto.UUID.generate}).entries
      0 = assert length Notif.notifs(conditions: {1, 10}, filters: %{}).entries
    end

    test "create a notif", context do
      {:error, :add, :notif, _notif_info} = assert Notif.create(%{user_id: context.user_info.id})
    end
  end
end
