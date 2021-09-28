defmodule MishkaDatabase.Public.Setting do

  alias MishkaDatabase.Schema.Public.Setting, as: SettingSchema

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: SettingSchema,
          error_atom: :setting,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :setting
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "setting")
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:setting)
  end

  def create(attrs, :no_pubsub) do
    crud_add(attrs)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:setting)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:setting)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end


  @spec settings([{:conditions, {String.t() | integer(), String.t() | integer()}} | {:filters, map()}, ...]) :: any
  def settings(conditions: {page, page_size}, filters: filters) do
    try do
      query = from(set in SettingSchema) |> convert_filters_to_where(filters)
      from([set] in query,
      order_by: [desc: set.inserted_at, desc: set.id],
      select: %{
        id: set.id,
        section: set.section,
        configs: set.configs,
        updated_at: set.updated_at,
        inserted_at: set.inserted_at,
      })
      |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
    rescue
      _db_error ->
        %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
    end
  end

  def settings(filters: filters) do
    try do
      query = from(set in SettingSchema) |> convert_filters_to_where(filters)
      from([set] in query,
      order_by: [desc: set.inserted_at, desc: set.id],
      select: %{
        id: set.id,
        section: set.section,
        configs: set.configs,
        updated_at: set.updated_at,
        inserted_at: set.inserted_at,
      })
      |> MishkaDatabase.Repo.all()
    rescue
      _db_error -> []
    end
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from set in query, where: field(set, ^key) == ^value
    end)
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: SettingSchema.__schema__(:fields)
  def allowed_fields(:string), do: SettingSchema.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :setting, repo_data} = params, type_send) do
    # send stop and re-create
    MishkaDatabase.Cache.SettingCache.stop()

    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "setting", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
