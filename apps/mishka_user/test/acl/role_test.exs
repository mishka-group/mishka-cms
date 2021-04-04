defmodule MishkaUserTest.Acl.RoleTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase
  alias MishkaUser.Acl.Role

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end


  describe "Happy | User Role Test with users DB (▰˘◡˘▰)" do
    test "create a role" do
      {:ok, :add, :role, _data} = assert Role.create(%{name: "admin", display_name: "admin"})
    end

    test "edit a role" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :edit, :role, _edit_data} = assert Role.edit(Map.merge(%{name: "edit", display_name: "edit"}, %{id: data.id}))
    end

    test "delete a role" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :delete, :role, _struct} = assert Role.delete(data.id)
    end

    test "show by id" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :get_record_by_id, :role, _record_info} = assert Role.show_by_id(data.id)
    end

    test "show by display name" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :get_record_by_field, :role, _record_info} = assert Role.show_by_display_name(data.display_name)
    end
  end




  describe "UnHappy | User Role Test with users DB ಠ╭╮ಠ" do
    test "create a role" do
      {:error, :add, :role, _changeset} = assert Role.create(%{display_name: "admin"})
    end

    test "edit a role" do
      {:error, :edit, :get_record_by_id, :role} = assert Role.edit(Map.merge(%{name: "edit", display_name: "edit"}, %{id: Ecto.UUID.generate}))
    end

    test "delete a role" do
      {:error, :delete, :get_record_by_id, :role} = assert Role.delete(Ecto.UUID.generate)
    end

    test "show by id" do
      {:error, :get_record_by_id, :role} = assert Role.show_by_id(Ecto.UUID.generate)
    end

    test "show by display name" do
      {:error, :get_record_by_field, :role} = assert Role.show_by_display_name("test")
    end
  end
end
