defmodule MishkaContent.General.Subscription do
  alias MishkaDatabase.Schema.MishkaContent.Subscription

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Subscription,
          error_atom: :subscription,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "subscription")
  end

  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:subscription)
  end

  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:subscription)
  end

  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:subscription)
  end

  def delete(user_id, section_id) do
    from(sub in Subscription, where: sub.user_id == ^user_id and sub.section_id == ^section_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :subscription, :not_found}
      comment -> delete(comment.id)
    end
  rescue
    Ecto.Query.CastError -> {:error, :delete, :subscription, :not_found}
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  # it should be asked how can we create  multi params of advanced search
  def subscriptions(conditions: {page, page_size}, filters: filters) do
    from(sub in Subscription, join: user in assoc(sub, :users)) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      case key do
        :full_name ->
          like = "%#{value}%"
          from([sub, user] in query, where: like(user.full_name, ^like))

        _ -> from [sub, user] in query, where: field(sub, ^key) == ^value
      end
    end)
  end

  defp fields(query) do
    from [sub, user] in query,
    order_by: [desc: sub.inserted_at, desc: sub.id],
    select: %{
      id: sub.id,
      status: sub.status,
      section: sub.section,
      section_id: sub.section_id,
      expire_time: sub.expire_time,
      extra: sub.extra,
      user_full_name: user.full_name,
      user_id: user.id,
      username: user.username,
      inserted_at: sub.inserted_at,
      updated_at: sub.updated_at
    }
  end

  def allowed_fields(:atom), do: Subscription.__schema__(:fields)
  def allowed_fields(:string), do: Subscription.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  def notify_subscribers({:ok, _, :subscription, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "subscription", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params
end
