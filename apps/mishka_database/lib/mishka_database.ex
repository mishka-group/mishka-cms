defmodule MishkaDatabase do
  @moduledoc """
  Documentation for `MishkaDatabase`.
  """

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
end
