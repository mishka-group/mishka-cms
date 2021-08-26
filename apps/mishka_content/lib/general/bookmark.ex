defmodule MishkaContent.General.Bookmark do
  alias MishkaDatabase.Schema.MishkaContent.Bookmark

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Bookmark,
          error_atom: :bookmark,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :bookmark
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

  @spec edit(record_input(), allowed_fields :: list()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}
  def delete(id) do
    crud_delete(id)
  end

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :delete, :bookmark | :forced_to_delete | :get_record_by_id | :uuid,
           :bookmark | :not_found | Ecto.Changeset.t()}
          | {:ok, :delete, :bookmark, %{optional(atom) => any}}
  def delete(user_id, section_id) do
    from(bm in Bookmark, where: bm.user_id == ^user_id and bm.section_id == ^section_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :bookmark, :not_found}
      comment -> delete(comment.id)
    end
  rescue
    Ecto.Query.CastError ->
      {:error, :delete, :bookmark, :not_found}
  end

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec user_all_bookmarks(data_uuid()) :: list()
  def user_all_bookmarks(user_id) do
    from(bk in Bookmark,
    where: bk.user_id == ^user_id,
    order_by: [desc: bk.inserted_at, desc: bk.id],
    select: %{
      id: bk.id,
      status: bk.status,
      section: bk.section,
      section_id: bk.section_id,
      extra: bk.extra,
      user_id: bk.user_id
    })
    |> MishkaDatabase.Repo.all()
  rescue
    Ecto.Query.CastError -> []
  end

  @spec bookmarks([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def bookmarks(conditions: {page, page_size}, filters: filters) do
    from(bk in Bookmark) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from bk in query, where: field(bk, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [bk] in query,
    join: user in assoc(bk, :users),
    order_by: [desc: bk.inserted_at, desc: bk.id],
    select: %{
      id: bk.id,
      status: bk.status,
      section: bk.section,
      section_id: bk.section_id,
      extra: bk.extra,
    }
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Bookmark.__schema__(:fields)
  def allowed_fields(:string), do: Bookmark.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
