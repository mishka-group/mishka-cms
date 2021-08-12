defmodule MishkaUserTest.Acl.PermissionTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaUser.Acl.{Role, Permission}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  describe "Happy | User Permission Test with users DB (▰˘◡˘▰)" do
    test "create a permission" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
    end

    test "edit a permission" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})

      {:ok, :edit, :permission, _edit_data} = assert Permission.edit(Map.merge(%{value: "Product:#{Ecto.UUID.generate}:view"}, %{id: permission_data.id}))
    end

    test "delete a permission" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:delete"})
      {:ok, :delete, :permission, _struct} = assert Permission.delete(permission_data.id)
    end

    test "show by id" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:delete"})

      {:ok, :get_record_by_id, :permission, _record_info} = assert Permission.show_by_id(permission_data.id)
    end

    test "delete role's permissions" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :delete, :role, _struct} = assert Role.delete(data.id)
      {:error, :get_record_by_id, :permission} = assert Permission.show_by_id(permission_data.id)
    end
  end




  describe "UnHappy | User Permission Test with users DB ಠ╭╮ಠ" do
    test "create a permission" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:error, :add, :permission, _permission_error} = assert Permission.create(%{role_id: data.id})
      {:error, :add, :permission, _permission_data} = assert Permission.create(%{role_id: Ecto.UUID.generate, value: "Product:#{Ecto.UUID.generate}:edit"})

      page_id = Ecto.UUID.generate
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{page_id}:edit"})
      {:error, :add, :permission, _duplicate_permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{page_id}:edit"})

    end

    test "edit a permission" do
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:delete"})

      {:error, :edit, :permission, _edit_data} = assert Permission.edit(Map.merge(%{value: "Product:#{Ecto.UUID.generate}:view", role_id: Ecto.UUID.generate}, %{id: permission_data.id}))
      {:error, :edit, :get_record_by_id, :permission} = assert Permission.edit(Map.merge(%{value: "Product:#{Ecto.UUID.generate}:view"}, %{id: Ecto.UUID.generate}))
    end

    test "delete a permission" do
      {:error, :delete, :get_record_by_id, :permission} = assert Permission.delete(Ecto.UUID.generate)
    end

    test "show by id" do
      {:error, :get_record_by_id, :permission} = assert Permission.show_by_id(Ecto.UUID.generate)
    end
  end
end
