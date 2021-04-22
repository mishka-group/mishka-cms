defmodule MishkaUser.Acl.UserRole do
  alias MishkaDatabase.Schema.MishkaUser.UserRole

  use MishkaDatabase.CRUD,
          module: UserRole,
          error_atom: :user_role,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def create(attrs) do
    crud_add(attrs)
  end

  def edit(attrs) do
    crud_edit(attrs)
  end

  def delete(id) do
    crud_delete(id)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

end
