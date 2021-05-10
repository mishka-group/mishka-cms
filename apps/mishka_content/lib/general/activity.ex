defmodule MishkaContent.General.Activity do

  alias MishkaDatabase.Schema.MishkaContent.Activity

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Activity,
          error_atom: :activity,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD


  def create(attrs) do
    crud_add(attrs)
  end

  def edit(attrs) do
    crud_edit(attrs)
  end

  def delete(id) do
    crud_delete(id)
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def activities(conditions: {page, page_size}, filters: filters) do
    from(activity in Activity) |> convert_filters_to_where(filters)
    |> field()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
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
