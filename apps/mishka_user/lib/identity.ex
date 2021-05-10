defmodule MishkaUser.Identity do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """
  alias MishkaDatabase.Schema.MishkaUser.IdentityProvider

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: IdentityProvider,
          error_atom: :identity,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :identity
  @type token() :: String.t()
  @type provider_uid() :: String.t()
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD


  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}

  def create(attrs) do
    crud_add(attrs)
  end


  @spec create(record_input(), allowed_fields :: list()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end


  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}

  def edit(attrs) do
    crud_edit(attrs)
  end


  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}

  def delete(id) do
    crud_delete(id)
  end


  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}

  def show_by_id(id) do
    crud_get_record(id)
  end


  @spec show_by_provider_uid(provider_uid()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}

  def show_by_provider_uid(provider_uid) do
    crud_get_by_field("provider_uid", provider_uid)
  end

  def identities(conditions: {page, page_size}, filters: filters) do
    from(identity in IdentityProvider) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from notif in query, where: field(notif, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [identity] in query,
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
  end
end
