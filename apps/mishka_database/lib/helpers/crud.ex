defmodule MishkaDatabase.CRUD do
  @moduledoc """
  ## Simplified CRUD macro using Ecto

  With this module, you can easily implement CRUD-related items in your file wherever you need to build a query.
  These modules and their sub-macros were created more to create a one-piece structure, and you can implement your own custom items in umbrella projects.
  In the first step, to use the following macros, you must bind the requested information in the relevant module that you have already created as follows.
  ```elixir
  use MishkaDatabase.CRUD,
                        module: YOURschemaMODULE,
                        error_atom: :your_error_tag,
                        repo: Your.Repo
  ```
  It should be noted that the following three parameters must be sent and also make sure you are connected to the database.

  ```elixir
  module
  error_atom
  repo
  ```
  """



  # MishkaUser.User custom Typespecs
  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: atom()
  @type email() :: String.t()
  @type username() :: String.t()
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()


  @callback create(record_input()) ::
            {:error, :add, error_tag(), repo_error()} |
            {:ok, :add, error_tag(), repo_data()}

  @callback edit(record_input()) ::
            {:error, :edit, :uuid, error_tag()} |
            {:error, :edit, :get_record_by_id, error_tag()} |
            {:error, :edit, error_tag(), repo_error()} |
            {:ok, :edit, error_tag(), repo_data()}

  @callback delete(data_uuid()) ::
            {:error, :delete, :uuid, error_tag()} |
            {:error, :delete, :get_record_by_id, error_tag()} |
            {:error, :delete, :forced_to_delete, error_tag()} |
            {:error, :delete, error_tag(), repo_error()} |
            {:ok, :delete, error_tag(), repo_data()}


  @callback show_by_id(data_uuid()) ::
            {:error, :get_record_by_id, error_tag()} |
            {:ok, :get_record_by_id, error_tag(), repo_data()}


  defmacro __using__(opts) do
    quote(bind_quoted: [opts: opts]) do
      import MishkaDatabase.CRUD
      @interface_module opts
    end
  end

  @doc """
  ### Creating a record macro

  ## Example
  ```elixir
  crud_add(map_of_info like: %{name: "trangell"})
  ```
  The input of this macro is a map and its output are a map. For example

  ```elixir
  {:ok, :add, error_atom, data}
  {:error, :add, error_atom, changeset}
  ```

  If you want only the selected parameters to be separated from the list of submitted parameters and sent to the database, use the same macro with input 2

  ###  Example
  ```elixir
  crud_add(map_of_info like: %{name: "trangell"}, [:name])
  ```
  """
  defmacro crud_add(attrs) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      add = module_selected.__struct__
      |> module_selected.changeset(unquote(attrs))
      |> repo.insert()
      case add do
        {:ok, data}             -> {:ok, :add, error_atom, data}
        {:error, changeset}     -> {:error, :add, error_atom, changeset}
      end
    end
  end

  defmacro crud_add(attrs, allowed_fields)  do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      add = module_selected.__struct__
      |> module_selected.changeset(Map.take(unquote(attrs), unquote(allowed_fields)))
      |> repo.insert()
      case add do
        {:ok, data}             -> {:ok, :add, error_atom, data}
        {:error, changeset}     -> {:error, :add, error_atom, changeset}
      end
    end
  end



  @doc """
  ### Edit a record in a database Macro

  With the help of this macro, you can edit a record in the database with its ID. For this purpose, you must send the requested record ID along with the new Map parameters. Otherwise the macro returns the ID error.

  ## Example
  ```elixir
  crud_edit(map_of_info like: %{id: "6d80d5f4-781b-4fa8-9796-1821804de6ba",name: "trangell"})
  ```
  > Note that the sending ID must be of UUID type.

  The input of this macro is a map and its output are a map. For example

  ```elixir
  # If your request has been saved successfully
  {:ok, :edit, error_atom, info}
  # If your ID is not uuid type
  {:error, :edit, error_atom, :uuid}
  # If there is an error in sending the data
  {:error, :edit, error_atom, changeset}
  # If no record is found for your ID
  {:error, :delete, error_atom, :get_record_by_id}
  ```

  It should be noted that if you want only the selected fields to be separated from the submitted parameters and sent to the database, use the macro with dual input.

  ## Example
  ```elixir
  crud_edit(map_of_info like: %{id: "6d80d5f4-781b-4fa8-9796-1821804de6ba", name: "trangell"}, [:id, :name])
  ```
  """
  defmacro crud_edit(attr) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.edit_record(unquote(attr), module_selected, error_atom, repo)
    end
  end

  defmacro crud_edit(attrs, allowed_fields)  do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.edit_record(Map.take(unquote(attrs), unquote(allowed_fields)), module_selected, error_atom, repo)
    end
  end


  @doc """
  ### delete a record from the database with the help of ID Macro

  With the help of this macro, you can delete your requested record from the database.
  The input of this macro is a UUID and its output is a map


  ## Example
  ```elixir
  crud_delete("6d80d5f4-781b-4fa8-9796-1821804de6ba")
  ```
  Output:
  You should note that this macro prevents the orphan data of the record requested to be deleted. So, use this macro when the other data is not dependent on the data with the ID sent by you.



  Outputs:

  ```elixir
  # This message will be returned when your data has been successfully deleted
  {:ok, :delete, error_atom, struct}
  # This error will be returned if the ID sent by you is not a UUID
  {:error, :delete, error_atom, :uuid}
  # This error is reversed when an error occurs while sending data
  {:error, :delete, error_atom, changeset}
  # This error will be reversed when there is no submitted ID in the database
  {:error, :delete, error_atom, :get_record_by_id}
  # This error is reversed when another record is associated with this record
  {:error, :delete, error_atom, :forced_to_delete}
  ```
  """
  defmacro crud_delete(id) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.delete_record(unquote(id), module_selected, error_atom, repo)
    end
  end


  @doc """
  ### Macro Finding a record in a database with the help of ID

  With the help of this macro, you can send an ID that is of UUID type and call it if there is a record in the database.
  The output of this macro is map.


  # Example
  ```elixir
  crud_get_record("6d80d5f4-781b-4fa8-9796-1821804de6ba")
  ```

  Outputs:

  ```
  {:error, error_atom, :get_record_by_id}
  {:ok, error_atom, :get_record_by_id, record_info}
  ```

  """
  defmacro crud_get_record(id) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)
      MishkaDatabase.CRUD.get_record_by_id(unquote(id), module_selected, error_atom, repo)
    end
  end


  @doc """
  ### Macro Find a record in the database with the help of the requested field

  With the help of this macro, you can find a field with the value you want, if it exists in the database. It should be noted that the field name must be entered as a String.


  # Example
  ```elixir
  crud_get_by_field("email", "info@trangell.com")
  ```

  Outputs:

  ```
  {:error, error_atom, :get_record_by_field}
  {:ok, error_atom, :get_record_by_field, record_info}
  ```

  """
  defmacro crud_get_by_field(field, value) do
    quote do
      module_selected = Keyword.get(@interface_module, :module)
      error_atom =  Keyword.get(@interface_module, :error_atom)
      repo =  Keyword.get(@interface_module, :repo)

      MishkaDatabase.CRUD.get_record_by_field(unquote(field), unquote(value), module_selected, error_atom, repo)
    end
  end





  # functions to create macro
  @doc false
  def update(changeset, attrs, module, repo) do
    module.changeset(changeset, attrs)
    |> repo.update
  end


  @doc false
  def uuid(id) do
    case Ecto.UUID.cast(id) do
      {:ok, record_id} -> {:ok, :uuid, record_id}
      _ -> {:error, :uuid}
    end
  end


  @doc false
  def get_record_by_id(id, module, error_atom, repo) do
    case repo.get(module, id) do
      nil -> {:error, :get_record_by_id, error_atom}
      record_info -> {:ok, :get_record_by_id, error_atom, record_info}
    end
  rescue
    _ -> {:error, :get_record_by_id, error_atom}
  end


  @doc false
  def get_record_by_field(field, value, module, error_atom, repo) do
    case repo.get_by(module, "#{field}": value) do
      nil -> {:error, :get_record_by_field, error_atom}
      record_info -> {:ok, :get_record_by_field, error_atom, record_info}
    end
  rescue
    _ -> {:error, :get_record_by_id, error_atom}
  end


  @doc false
  def edit_record(attrs, module, error_atom, repo) do
    with {:ok, :uuid, record_id} <- uuid(if Map.has_key?(attrs, :id), do: attrs.id, else: attrs["id"]),
        {:ok, :get_record_by_id, error_atom, record_info} <- get_record_by_id(record_id, module, error_atom, repo),
        {:ok, info} <- update(record_info, attrs, module, repo) do

        {:ok, :edit, error_atom, info}
      else
        {:error, :uuid} ->
          {:error, :edit, :uuid, error_atom}

        {:error, changeset} ->
          {:error, :edit, error_atom, changeset}

        _ ->
          {:error, :edit, :get_record_by_id, error_atom}
    end
  end


  @doc false
  def delete_record(id, module, error_atom, repo) do
    try do
      with {:ok, :uuid, record_id} <- uuid(id),
           {:ok, :get_record_by_id, error_atom, record_info} <- get_record_by_id(record_id, module, error_atom, repo),
           {:ok, struct} <- repo.delete(record_info) do

        {:ok, :delete, error_atom, struct}
      else
        {:error, :uuid} ->
          {:error, :delete, :uuid, error_atom}

        {:error, changeset} ->
          {:error, :delete, error_atom, changeset}

        _ ->
          {:error, :delete, :get_record_by_id, error_atom}
      end
    rescue
      _e in Ecto.ConstraintError -> {:error, :delete, :forced_to_delete, error_atom}
    end
  end

end
