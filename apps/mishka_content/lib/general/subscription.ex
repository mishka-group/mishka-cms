defmodule MishkaContent.General.Subscription do
  alias MishkaDatabase.Schema.MishkaContent.Subscription

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Subscription,
          error_atom: :subscription,
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

  def delete(user_id, section_id) do
    [user_id, section_id]
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  # it should be asked how can we create  multi params of advanced search
  def subscription(conditions: {page, page_size}, filters: filters) do
    from(sub in Subscription) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from sub in query, where: field(sub, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [sub] in query,
    join: user in assoc(sub, :users),
    order_by: [desc: sub.inserted_at, desc: sub.id],
    select: %{
      id: sub.id,
      status: sub.status,
      section: sub.section,
      section_id: sub.section_id,
      expire_time: sub.expire_time,
      extra: sub.extra,
    }
  end
end
