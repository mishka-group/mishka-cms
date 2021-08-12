defmodule MishkaUserTest.Acl.UserRolTest do
  use ExUnit.Case, async: true
  doctest MishkaDatabase

  alias MishkaUser.Acl.{Role, Permission, UserRole}
  alias MishkaUser.User

  @right_user_info %{
    "full_name" => "username",
    "username" => "usernameuniq",
    "email" => "user_name_@gmail.com",
    "password" => "pass1Test",
    "status" => 1,
    "unconfirmed_email" => "user_name_#{Enum.random(100000..999999)}@gmail.com",
  }


  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  describe "Happy | UserRolTest Test with users DB (▰˘◡˘▰)" do
    test "create a user role" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :user_role, _user_role_data} = assert UserRole.create(%{role_id: data.id, user_id: user_data.id})
    end

    test "edit a user role" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :user_role, user_role_data} = assert UserRole.create(%{role_id: data.id, user_id: user_data.id})


      {:ok, :add, :role, new_role_data} = assert Role.create(%{name: "edit", display_name: "edit"})
      {:ok, :edit, :user_role, _edit_data} = assert UserRole.edit(Map.merge(%{role_id: new_role_data.id, user_id: user_data.id}, %{id: user_role_data.id}))
    end

    test "delete a user role" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :user_role, user_role_data} = assert UserRole.create(%{role_id: data.id, user_id: user_data.id})


      {:ok, :delete, :user_role, _struct} = assert UserRole.delete(user_role_data.id)
    end


    test "delete a user role with a user" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :user_role, user_role_data} = assert UserRole.create(%{role_id: data.id, user_id: user_data.id})

      {:ok, :delete, :user, _struct} = assert User.delete(user_data.id)

      {:error, :get_record_by_id, :user_role} = assert UserRole.show_by_id(user_role_data.id)
    end

    test "delete a user role with a role_id" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, role_data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: role_data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :user_role, user_role_data} = assert UserRole.create(%{role_id: role_data.id, user_id: user_data.id})

      {:ok, :delete, :role, _struct} = assert Role.delete(role_data.id)

      {:error, :get_record_by_id, :user_role} = assert UserRole.show_by_id(user_role_data.id)
    end


    test "show by id" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, role_data} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :permission, _permission_data} = assert Permission.create(%{role_id: role_data.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :user_role, user_role_data} = assert UserRole.create(%{role_id: role_data.id, user_id: user_data.id})


      {:ok, :get_record_by_id, :user_role, _record_info} = assert UserRole.show_by_id(user_role_data.id)
    end

    test "get all users role and permissions" do
      {:ok, :add, :user, user_data} = assert User.create(@right_user_info)
      {:ok, :add, :role, role_admin} = assert Role.create(%{name: "admin", display_name: "admin"})
      {:ok, :add, :role, role_shop_editor} = assert Role.create(%{name: "editor", display_name: "editor"})

      {:ok, :add, :permission, _permission_data_one} = assert Permission.create(%{role_id: role_admin.id, value: "Product:#{Ecto.UUID.generate}:edit"})
      {:ok, :add, :permission, _permission_data_two} = assert Permission.create(%{role_id: role_shop_editor.id, value: "Shop:#{Ecto.UUID.generate}:editor"})

      {:ok, :add, :user_role, _user_role_data} = assert UserRole.create(%{role_id: role_admin.id, user_id: user_data.id})
      {:ok, :add, :user_role, _user_role_data} = assert UserRole.create(%{role_id: role_shop_editor.id, user_id: user_data.id})

      2 = assert Enum.count(User.permissions(user_data.id))
    end
  end


end
