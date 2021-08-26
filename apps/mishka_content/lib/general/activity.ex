defmodule MishkaContent.General.Activity do

  alias MishkaDatabase.Schema.MishkaContent.Activity

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Activity,
          error_atom: :activity,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :activity
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}
  def create(attrs) do
    crud_add(attrs)
  end

  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs) do
    crud_edit(attrs)
  end

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}
  def delete(id) do
    crud_delete(id)
  end

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec activities([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def activities(conditions: {page, page_size}, filters: filters) do
    from(activity in Activity) |> convert_filters_to_where(filters)
    |> field()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from activity in query, where: field(activity, ^key) == ^value
    end)
  end

  defp field(query) do
    from [activity] in query,
    select: %{
      id: activity.id,
      type: activity.type,
      section: activity.section,
      section_id: activity.section_id,
      priority: activity.priority,
      status: activity.status,
      action: activity.action,
      extra: activity.extra,
    }
  end
end
