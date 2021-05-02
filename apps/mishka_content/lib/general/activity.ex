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

  # it should be changed, this is a dirty code and I need to improve it as mocro or any way which can simple
  def activities(condition: %{paginate: {page, page_size}, type: type, section: section, section_id: section_id, priority: priority, status: status, action: action
  }) do
    from(activity in Activity,
      where: activity.type == ^type,
      where: activity.section == ^section,
      where: activity.section_id == ^section_id,
      where: activity.priority == ^priority,
      where: activity.status == ^status,
      where: activity.action == ^action)
    |> field()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def activities(condition: %{paginate: {page, page_size}}) do
    from(activity in Activity)
    |> field()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
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
