defmodule MishkaContent.General.Subscription do
  alias MishkaDatabase.Schema.MishkaContent.Subscription

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Subscription,
          error_atom: :subscription,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :subscription
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "subscription")
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:subscription)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:subscription)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:subscription)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:subscription)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:subscription)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :delete, :forced_to_delete | :get_record_by_id | :subscription | :uuid,
           :not_found | :subscription | Ecto.Changeset.t()}
          | {:ok, :delete, :subscription, %{optional(atom) => any}}
  def delete(user_id, section_id) do
    from(sub in Subscription, where: sub.user_id == ^user_id and sub.section_id == ^section_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :subscription, :not_found}
      comment -> delete(comment.id)
    end
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("subscription", "delete", db_error)
      {:error, :delete, :subscription, :not_found}
  end

  @spec subscriptions([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def subscriptions(conditions: {page, page_size}, filters: filters) do
    from(sub in Subscription, join: user in assoc(sub, :users)) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("subscription", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :full_name ->
          like = "%#{value}%"
          from([sub, user] in query, where: like(user.full_name, ^like))

        _ -> from [sub, user] in query, where: field(sub, ^key) == ^value
      end
    end)
  end

  defp fields(query) do
    from [sub, user] in query,
    order_by: [desc: sub.inserted_at, desc: sub.id],
    select: %{
      id: sub.id,
      status: sub.status,
      section: sub.section,
      section_id: sub.section_id,
      expire_time: sub.expire_time,
      extra: sub.extra,
      user_full_name: user.full_name,
      user_id: user.id,
      username: user.username,
      inserted_at: sub.inserted_at,
      updated_at: sub.updated_at
    }
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Subscription.__schema__(:fields)
  def allowed_fields(:string), do: Subscription.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :subscription, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "subscription", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
