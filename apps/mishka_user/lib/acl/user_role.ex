defmodule MishkaUser.Acl.UserRole do
  alias MishkaDatabase.Schema.MishkaUser.UserRole
  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: UserRole,
          error_atom: :user_role,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :user_role
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec show_by_user_id(data_uuid()) ::
  {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_user_id(user_id) do
    crud_get_by_field("user_id", user_id)
  end


  @spec delete_user_role(data_uuid()) ::
          {:error, :delete_user_role, :not_found}
          | {:error, :delete, :forced_to_delete | :get_record_by_id | :user_role | :uuid,
             :user_role | Ecto.Changeset.t()}
          | {:ok, :delete, :user_role, %{optional(atom) => any}}
  def delete_user_role(user_id) do
    case show_by_user_id(user_id) do
      {:ok, :get_record_by_field, :user_role, record} -> delete(record.id)
      _ -> {:error, :delete_user_role, :not_found}
    end
  end

  @spec roles(data_uuid()) :: any
  def roles(role_id) do
    stream = from(u in UserRole, where: u.role_id == ^role_id,
    select: %{
      id: u.id, user_id: u.user_id, role_id: u.role_id
    })
    |> MishkaDatabase.Repo.stream()

    MishkaDatabase.Repo.transaction(fn() ->
      Enum.to_list(stream)
    end)
  end
end
