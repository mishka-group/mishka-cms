defmodule MishkaContent.General.Notif do
  alias MishkaDatabase.Schema.MishkaContent.Notif

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Notif,
          error_atom: :notif,
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


  # it should be asked how can we create  multi params of advanced search
  def notifs(user_id, condition: %{paginate: {page, page_size}}) do
    from(notif in Notif,
    where: notif.user_id == ^user_id,
    join: user in assoc(notif, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  def notifs(condition: %{paginate: {page, page_size}}) do
    from(notif in Notif,
    join: user in assoc(notif, :users))
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  end

  defp fields(query) do
    from [notif, user] in query,
    order_by: [desc: notif.inserted_at, desc: notif.id],
    select: %{
      id: notif.id,
      status: notif.status,
      section: notif.section,
      section_id: notif.section_id,
      short_description: notif.short_description,
      expire_time: notif.expire_time,
      extra: notif.extra,
    }
  end

end
