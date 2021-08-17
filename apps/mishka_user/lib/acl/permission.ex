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

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "permission")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:permission)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:permission)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:permission)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

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

  def notify_subscribers({:ok, _, :permission, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "permission", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
