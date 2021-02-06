defmodule MishkaDatabaseCrudMacroTest do
  use ExUnit.Case
  doctest MishkaDatabase
  use MishkaDatabase.CRUD,
                        module: MishkaDatabase.Schema.MishkaUser.User,
                        error_atom: :user,
                        repo: MishkaDatabase.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDatabase.Repo)
  end

  @right_user_info %{
    full_name: "username",
    username: "usernameuniq",
    email: "user_name_@gmail.com",
    password: "pass1Test",
    status: 1,
    unconfirmed_email: "user_name_#{Enum.random(100000..999999)}@gmail.com",
  }

  @false_user_info %{
    username: "usernameuniq",
    email: "user_name_@gmail.com",
    password: "pass1Test"
  }

  describe "Happy | CRUD Macro with users DB (▰˘◡˘▰)" do
    test "crud add without strong parameter (user right info)" do
      {:ok, :add, :user, _data} = assert crud_add(@right_user_info)
    end

    test "crud add with strong parameter (user right info)" do
      allowed_fields = [:full_name, :username, :email, :status]
      {:ok, :add, :user, _data} = assert crud_add(@right_user_info, allowed_fields)
    end

    test "crud edit without strong parameter (user right info)" do
      allowed_fields = [:full_name, :username, :email, :status]
      {:ok, :add, :user, data} = assert crud_add(@right_user_info, allowed_fields)
      {:ok, :edit, :user, _edit_data} = assert crud_edit(Map.merge(@right_user_info,%{id: data.id}))
    end

    test "crud edit with strong parameter (user right info)" do
      allowed_fields = [:id, :full_name, :username, :email, :status]
      {:ok, :add, :user, data} = assert crud_add(@right_user_info)
      {:ok, :edit, :user, _edit_data} = assert crud_edit(Map.merge(@right_user_info, %{id: data.id}), allowed_fields)
    end

    test "crud delete (user right info)" do
      {:ok, :add, :user, data} = assert crud_add(@right_user_info)
      {:ok, :delete, :user, _struct} = assert crud_delete(data.id)
    end

    test "get record by id (user right info)" do
      {:ok, :add, :user, data} = assert crud_add(@right_user_info)
      {:ok, :get_record_by_id, :user, _record_info} = assert crud_get_record(data.id)
    end

    test "get record by field (user right info)" do
      {:ok, :add, :user, data} = assert crud_add(@right_user_info)
      {:ok, :get_record_by_field, :user, _record_info} = assert crud_get_by_field("email", data.email)
    end
  end






  describe "UnHappy | CRUD Macro with users DB ಠ╭╮ಠ" do
    test "crud add without strong parameter (user false info)" do
      {:error, :add, :user, _changeset} = assert crud_add(@false_user_info)
    end

    test "crud add with strong parameter (user false info)" do
      allowed_fields = [:full_name]
      {:error, :add, :user, _changeset} = assert crud_add(@false_user_info, allowed_fields)
    end

    test "crud edit without strong parameter (user right info)" do
      allowed_fields = [:full_name, :username, :email, :status]
      {:ok, :add, :user, data} = assert crud_add(@right_user_info, allowed_fields)
      {:error, :edit, :user, _changeset} = assert crud_edit(Map.merge(@false_user_info,%{id: data.id, full_name: "f"}))
    end

    test "crud edit with strong parameter (user right info)" do
      allowed_fields = [:id, :full_name, :username, :email, :status]
      {:ok, :add, :user, data} = assert crud_add(@right_user_info)
      {:error, :edit, :user, _changeset} = assert crud_edit(Map.merge(@false_user_info, %{id: data.id, full_name: "f"}), allowed_fields)
    end

    test "crud delete (user false info)" do
      {:error, :delete, :get_record_by_id, :user} = assert crud_delete(Ecto.UUID.generate)
    end

    test "get record by id (user false info)" do
      {:error, :get_record_by_id, :user} = assert crud_get_record(Ecto.UUID.generate)
    end

    test "get record by field (user false info)" do
      {:error, :get_record_by_field, :user} = assert crud_get_by_field("email", "test@test.com")
    end
  end
end
