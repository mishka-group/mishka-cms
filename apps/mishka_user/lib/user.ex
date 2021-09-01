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


  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "user")
  end

  @doc """
    this function starts push notification in this module.
  """

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:user)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:user)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:user)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:user)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:user)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
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

  @spec users([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def users(conditions: {page, page_size}, filters: filters) do
    from(u in User, left_join: roles in assoc(u, :roles)) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :role ->
          from [u, roles] in query, where: field(roles, :id) == ^value

        :full_name ->
          like = "%#{value}%"
          from [u, roles] in query, where: like(u.full_name, ^like)

        :username ->
          like = "%#{value}%"
          from [u, roles] in query, where: like(u.username, ^like)

        :email ->
          like = "%#{value}%"
          from [u, roles] in query, where: like(u.email, ^like)

        _ -> from [u, roles] in query, where: field(u, ^key) == ^value
      end
    end)
  end

  defp fields(query) do
    from [u, roles] in query,
    order_by: [desc: u.inserted_at, desc: u.id],
    select: %{
      id: u.id,
      full_name: u.full_name,
      username: u.username,
      email: u.email,
      status: u.status,
      unconfirmed_email: u.unconfirmed_email,
      inserted_at: u.inserted_at,
      updated_at: u.updated_at,
      roles: roles
    }
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: User.__schema__(:fields)
  def allowed_fields(:string), do: User.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :user, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "user", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
