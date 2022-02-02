defmodule MishkaInstaller.Plugin do

  alias MishkaDatabase.Schema.MishkaInstaller.Plugin, as: PluginSchema
  # import Ecto.Query
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
    event_atom_to_string(attrs)
    |> crud_add()
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    event_atom_to_string(attrs)
    |> crud_add(allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    event_atom_to_string(attrs)
    |> crud_edit()
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    event_atom_to_string(attrs)
    |> crud_edit(allowed_fields)
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

  def edit_by_name(state) do
    case show_by_name("#{state.name}") do
      {:ok, :get_record_by_field, :plugin, repo_data} -> edit(state |> Map.merge(%{id: repo_data.id}))
      _ -> {:error, :edit_by_name, :not_found}
    end
  end

  defp event_atom_to_string(%{name: name, event: event} = attrs) when is_atom(name) and is_atom(event) do
    attrs
    |> Map.merge(%{name: Atom.to_string(name), event: Atom.to_string(event)})
  end

  defp event_atom_to_string(attrs), do: attrs
end
