defmodule MishkaUser.Acl.Role do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """
  alias MishkaDatabase.Schema.MishkaUser.Role

  use MishkaDatabase.CRUD,
          module: Role,
          error_atom: :role,
          repo: MishkaDatabase.Repo


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

  def show_by_display_name(name) do
    crud_get_by_field("name", name)
  end

end
