defmodule MishkaUser.Token.UserToken do
  import Ecto.Query
  alias MishkaDatabase.Schema.MishkaUser.UserToken

  use MishkaDeveloperTools.DB.CRUD,
      module: UserToken,
      error_atom: :user_token,
      repo: MishkaDatabase.Repo


  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "user_token")
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:user_token)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:user_token)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:user_token)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  def show_by_token(token) do
    crud_get_by_field("token", token)
  end

  def show_by_user_id(user_id) do
    from(t in UserToken, where: t.user_id == ^user_id)
    |> fields()
    |> MishkaDatabase.Repo.all()
  end

  def delete_by_token(token) when is_binary(token) do
    from(t in UserToken, where: t.token == ^token)
    |> MishkaDatabase.Repo.delete_all
  end

  def delete_by_token(token_info) do
    from(t in UserToken, where: t.token == ^token_info.token)
    |> MishkaDatabase.Repo.delete_all
  end

  def delete_by_user_id(user_id) when is_binary(user_id) do
    from(t in UserToken, where: t.user_id == ^user_id)
    |> MishkaDatabase.Repo.delete_all
  end

  # Ref: https://elixirforum.com/t/48594
  def delete_expire_token() do
    stream =
      from(t in UserToken, where: t.expire_time < ^DateTime.utc_now)
      |> MishkaDatabase.Repo.stream()

    MishkaDatabase.Repo.transaction(fn() ->
      stream
      |> Task.async_stream(&delete(&1.id), max_concurrency: 10)
      |> Stream.run
    end)
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: UserToken.__schema__(:fields)
  def allowed_fields(:string), do: UserToken.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :user_token, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "user_token", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params

  defp fields(query) do
    from [t] in query,
    order_by: [desc: t.inserted_at, desc: t.id],
    select: %{
      id: t.id,
      token: t.token,
      type: t.type,
      expire_time: t.expire_time,
      extra: t.extra,
      inserted_at: t.inserted_at,
      updated_at: t.updated_at,
    }
  end
end
