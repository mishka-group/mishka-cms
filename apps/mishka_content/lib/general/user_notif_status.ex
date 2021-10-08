defmodule MishkaContent.General.UserNotifStatus do

  alias MishkaDatabase.Schema.MishkaContent.UserNotifStatus

  use MishkaDatabase.CRUD,
          module: UserNotifStatus,
          error_atom: :user_notif_status,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :subscription
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
end
