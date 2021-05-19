defmodule MishkaDatabase do
  @moduledoc """
  Documentation for `MishkaDatabase`.
  """
  import Ecto.Changeset
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
    end)
  end

  def convert_string_map_to_atom_map(map) do
    map
    |> Map.new(fn {k, v} ->
        {String.to_existing_atom(k), v}
    end)
  end

  def validate_binary_id(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, uuid ->
      case uuid(uuid) do
        {:ok, :uuid, _record_id} -> []
        {:error, :uuid} -> [{field, options[:message] || "ID should be as a UUID type."}]
      end
    end)
  end

  def uuid(id) do
    case Ecto.UUID.cast(id) do
      {:ok, record_id} -> {:ok, :uuid, record_id}
      _ -> {:error, :uuid}
    end
  end
end
