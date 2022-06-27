defmodule MishkaUser.Identity do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """
  alias MishkaDatabase.Schema.MishkaUser.IdentityProvider

  import Ecto.Query

  use MishkaDeveloperTools.DB.CRUD,
    module: IdentityProvider,
    error_atom: :identity,
    repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t()
  @type record_input() :: map()
  @type error_tag() :: :identity
  @type token() :: String.t()
  @type provider_uid() :: String.t()
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDeveloperTools.DB.CRUD

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec show_by_provider_uid(provider_uid()) ::
          {:error, :get_record_by_field, error_tag()}
          | {:ok, :get_record_by_field, error_tag(), repo_data()}

  def show_by_provider_uid(provider_uid) do
    crud_get_by_field("provider_uid", provider_uid)
  end

  @spec identities([
          {:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()},
          ...
        ]) :: Scrivener.Page.t()
  def identities(conditions: {page, page_size}, filters: filters) do
    from(identity in IdentityProvider)
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("identity", "read", db_error)

      %Scrivener.Page{
        entries: [],
        page_number: 1,
        page_size: page_size,
        total_entries: 0,
        total_pages: 1
      }
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from(notif in query, where: field(notif, ^key) == ^value)
    end)
  end

  defp fields(query) do
    from([identity] in query,
      join: user in assoc(identity, :users),
      order_by: [desc: identity.inserted_at, desc: identity.id],
      select: %{
        id: identity.id,
        provider_uid: identity.provider_uid,
        token: identity.token,
        identity_provider: identity.identity_provider,
        user_full_name: user.full_name,
        user_username: user.username,
        user_id: user.id
      }
    )
  end
end
