defmodule MishkaInstaller.Plugin do

  alias MishkaDatabase.Schema.MishkaInstaller.Plugin, as: PluginSchema
  alias MishkaInstaller.PluginState
  import Ecto.Query
  use MishkaDeveloperTools.DB.CRUD,
          module: PluginSchema,
          error_atom: :plugin,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :plugin
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

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_by_field, 2}
  def show_by_name(name) do
    crud_get_by_field("name", name)
  end

  def add_or_edit_by_name(state) do
    case show_by_name("#{state.name}") do
      {:ok, :get_record_by_field, :plugin, repo_data} -> edit(state |> Map.merge(%{id: repo_data.id}))
      _ -> create(state)
    end
  end

  def plugins(event: event) do
    from(plg in PluginSchema, where: plg.event == ^event)
    |> fields()
    |> MishkaDatabase.Repo.all()
    |> Enum.map(&struct(PluginState, &1))
  end

  def plugins() do
    from(plg in PluginSchema)
    |> fields()
    |> MishkaDatabase.Repo.all()
    |> Enum.map(&struct(PluginState, &1))
  end

  defp fields(query) do
    from [plg] in query,
    order_by: [desc: plg.inserted_at, desc: plg.id],
    select: %{
      name: plg.name,
      event: plg.event,
      priority: plg.priority,
      status: plg.status,
      depend_type: plg.depend_type,
      depends: plg.depends
    }
  end

  def delete_plugins(event) do
    stream = MishkaDatabase.Repo.stream(from(plg in PluginSchema))
    MishkaDatabase.Repo.transaction(fn() ->
      stream
      |> Stream.filter(&(event in &1.depends))
      |> Enum.to_list()
    end)
    |> case do
      {:ok, list} ->
        list
        |> Task.async_stream(&MishkaInstaller.Hook.unregister(module: &1.name), max_concurrency: 20)
        |> Stream.run
      error ->
        # TODO: Shoule be stored on Activity db
        IO.inspect(error)
    end
  end
end
