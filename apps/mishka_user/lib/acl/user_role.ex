defmodule MishkaUser.Acl.UserRole do
  alias MishkaDatabase.Schema.MishkaUser.UserRole

  use MishkaDatabase.CRUD,
          module: UserRole,
          error_atom: :user_role,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD
  import Ecto.Query

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

  def show_by_user_id(user_id) do
    crud_get_by_field("user_id", user_id)
  end


  def delete_user_role(user_id) do
    case show_by_user_id(user_id) do
      {:ok, :get_record_by_field, :user_role, record} -> delete(record.id)
      _ -> {:error, :delete_user_role, :not_found}
    end
  end

  def roles(role_id) do
    stream = from(u in UserRole, where: u.role_id == ^role_id, select: %{
      id: u.id, user_id: u.user_id, role_id: u.role_id
    })
    |> MishkaDatabase.Repo.stream()

    MishkaDatabase.Repo.transaction(fn() ->
      Enum.to_list(stream)
    end)
  end
end
