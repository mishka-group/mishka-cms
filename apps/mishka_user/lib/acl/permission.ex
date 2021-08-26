defmodule MishkaUser.Acl.Permission do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """
  alias MishkaDatabase.Schema.MishkaUser.Permission
  import Ecto.Query

  use MishkaDatabase.CRUD,
          module: Permission,
          error_atom: :permission,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :permission
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "permission")
  end

  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:permission)
  end

  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:permission)
  end

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:permission)
  end

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec permissions(data_uuid()) :: list()
  def permissions(role_id) do
    from(permission in Permission,
      where: permission.role_id == ^role_id,
      join: role in assoc(permission, :roles),
      select: %{
        id: permission.id,
        value: permission.value,
        role_id: permission.role_id,
        role_name: role.name,
        role_display_name: role.display_name

      })
    |> MishkaDatabase.Repo.all()
  rescue
    Ecto.Query.CastError -> []
  end

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :permission, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "permission", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
