defmodule MishkaUser.User do
  @moduledoc """
    this module helps us to handle users and connect to users database.
    this module is tested in MishkaDatabase CRUD macro
  """

  import Ecto.Query
  alias MishkaDatabase.Schema.MishkaUser.User

  use MishkaDatabase.CRUD,
          module: User,
          error_atom: :user,
          repo: MishkaDatabase.Repo


  # MishkaUser.User custom Typespecs
  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :user
  @type email() :: String.t()
  @type username() :: String.t()
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()
  @type password() :: String.t()

  @behaviour MishkaDatabase.CRUD

  @doc """
    this function starts push notification in this module.
  """

  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}

  def create(attrs) do
    crud_add(Map.merge(attrs, %{"unconfirmed_email" => attrs["email"]}))
  end


  @spec create(record_input(), allowed_fields :: list()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}

  def create(attrs, allowed_fields) do
    crud_add(Map.merge(attrs, %{"unconfirmed_email" => attrs["email"]}), allowed_fields)
  end

  @doc """
    this function starts push notification in this module.
  """

  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}

  def edit(attrs) do
    crud_edit(attrs)
  end


  @doc """
    this function starts push notification in this module.
  """

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}

  def delete(id) do
    crud_delete(id)
  end


  @doc """
    this function starts push notification in this module.
  """

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}

  def show_by_id(id) do
    crud_get_record(id)
  end


  @doc """
    this function starts push notification in this module.
  """

  @spec show_by_email(email()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}

  def show_by_email(email) do
    crud_get_by_field("email", email)
  end

  @doc """
    this function starts push notification in this module.
  """

  @spec show_by_username(username()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_username(username) do
    crud_get_by_field("username", username)
  end


  @doc """
    this function starts push notification in this module.
  """

  @spec show_by_unconfirmed_email(email()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_unconfirmed_email(email) do
    crud_get_by_field("unconfirmed_email", email)
  end


  @spec check_password(repo_data(), password()) ::
          {:error, :check_password, :user} | {:ok, :check_password, :user}
  def check_password(user_info, password) do
    case Bcrypt.check_pass(user_info, "#{password}") do
      {:ok, _params} -> {:ok, :check_password, :user}
      _ -> {:error, :check_password, :user}
    end
  end


  @spec active?(atom()) :: {:error, :active?, atom()} | {:ok, :active?, :active | :inactive}
  def active?(user_status) do
    user_status
    |> case do
      :active -> {:ok, :active?, :active}
      :inactive -> {:ok, :active?, :inactive}
      status -> {:error, :active?, status}
    end
  end

  @spec permissions(data_uuid()) :: list()
  def permissions(id) do
    query = from user in User,
      where: user.id == ^id,
      join: roles in assoc(user, :roles),
      join: permissions in assoc(roles, :permissions),
      select: %{
        value: permissions.value,
      }
    MishkaDatabase.Repo.all(query)
  rescue
    Ecto.Query.CastError -> []
  end

end
