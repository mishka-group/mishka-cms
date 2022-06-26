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

  def delete_by_token(token) do
    from(t in UserToken, where: t.token == ^token)
    |> MishkaDatabase.Repo.delete_all
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: UserToken.__schema__(:fields)
  def allowed_fields(:string), do: UserToken.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :user_token, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "user_token", {type_send, :ok, repo_data})
    params
  end


  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # def delete_token(token) do
  #   Mnesia.transaction(fn -> Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$3", "#{token}"}], [:"$$"]}]) end)
  #   |> case do
  #     {:atomic, data} ->
  #       Enum.map(data, fn [id, _user_id, _token, _exp_time, _create_time, _os] -> Mnesia.dirty_delete(Token, id) end)
  #       :ok
  #     _ -> :ok
  #   end
  # end

  # def delete_expierd_token(user_id) do
  #   Mnesia.transaction(fn -> Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}]) end)
  #   |> case do
  #     {:atomic, data} when is_list(data) ->
  #       Enum.map(data, fn [id, _user_id, _token, access_expires_in, _create_time, _os] ->
  #         if access_expires_in <= System.system_time(:second) do
  #           Mnesia.dirty_delete(Token, id)
  #         end
  #         :ok
  #       end)
  #     _ -> :ok
  #   end
  # end

  # def delete_all_user_tokens(user_id) do
  #   Mnesia.transaction(fn -> Mnesia.select(Token, [{{Token, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"}, [{:"==", :"$2", "#{user_id}"}], [:"$$"]}]) end)
  #   |> case do
  #     {:atomic, data} when is_list(data)->
  #       Enum.map(data, fn [id, _user_id, _token, _access_expires_in, _create_time, _os] -> Mnesia.dirty_delete(Token, id) end)
  #       :ok
  #     _ -> :ok
  #   end
  # end
end
