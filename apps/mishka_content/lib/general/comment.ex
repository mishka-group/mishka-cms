defmodule MishkaContent.General.Comment do
  alias MishkaDatabase.Schema.MishkaContent.Comment
  alias MishkaContent.General.CommentLike
  alias MishkaContent.General.Notif

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: Comment,
          error_atom: :comment,
          repo: MishkaDatabase.Repo


  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :comment
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "comment")
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:comment)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:comment)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:comment)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:comment)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:comment)
  end

  @doc delegate_to: {MishkaDatabase.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :edit, :comment | :get_record_by_id | :uuid,
           :comment | :not_found | Ecto.Changeset.t()}
          | {:ok, :edit, :comment, %{optional(atom) => any}}
  def delete(user_id, id) do
    from(com in Comment, where: com.user_id == ^user_id and com.id == ^id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :edit, :comment, :not_found}
      comment -> edit(%{id: comment.id, status: :soft_delete})
    end
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("comment", "delete", db_error)
      {:error, :edit, :comment, :not_found}
  end

  @spec show_by_user_id(data_uuid()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_user_id(user_id) do
    crud_get_by_field("user_id", user_id)
  end

  @spec comments([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()} | {:user_id, nil | data_uuid()}, ...]) ::
          Scrivener.Page.t()
  def comments(conditions: {page, page_size}, filters: filters, user_id: user_id) when is_binary(user_id) or is_nil(user_id) do
    user_id = if(!is_nil(user_id), do: user_id, else: Ecto.UUID.generate)

    from(com in Comment,
    join: user in assoc(com, :users),
    left_join: like in assoc(com, :comments_likes),
    left_join: liked_user in subquery(CommentLike.user_liked()),
    on: liked_user.user_id == ^user_id and liked_user.comment_id == com.id
    )
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("comment", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  @spec comment([{:filters, map()} | {:user_id, data_uuid()}, ...]) :: map() | nil
  def comment(filters: filters, user_id: user_id) do
    user_id = if(!is_nil(user_id), do: user_id, else: Ecto.UUID.generate)

    from(com in Comment,
    join: user in assoc(com, :users),
    left_join: like in assoc(com, :comments_likes),
    left_join: liked_user in subquery(CommentLike.user_liked()),
    on: liked_user.user_id == ^user_id and liked_user.comment_id == com.id
    )
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.one()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("comment", "read", db_error)
      nil
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from [com, user, like, liked_user] in query, where: field(com, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [com, user, like, liked_user] in query,
    order_by: [desc: com.inserted_at, desc: com.id],
    group_by: [com.id, user.id, like.comment_id, liked_user.comment_id, liked_user.user_id],
    select: %{
      id: com.id,
      description: com.description,
      status: com.status,
      priority: com.priority,
      sub: com.sub,
      section: com.section,
      section_id: com.section_id,
      updated_at: com.updated_at,
      inserted_at: com.inserted_at,

      user_id: user.id,
      user_full_name: user.full_name,
      user_username: user.username,
      like_count: count(like.id),
      liked_user: liked_user
    }
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: Comment.__schema__(:fields)
  def allowed_fields(:string), do: Comment.__schema__(:fields) |> Enum.map(&Atom.to_string/1)

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :comment, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "comment", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params

  def send_notification?(comment_id, user_id, title, description) do
    with {:ok, :get_record_by_id, _error_tag, record_info} <- show_by_id(comment_id),
         {:same_user?, false} <- {:same_user?, record_info.user_id == user_id} do

          Notif.send_notification(%{
            section: :blog_post,
            section_id: record_info.section_id,
            type: :client,
            target: :all,
            title: title,
            description: description
          }, record_info.user_id, :repo_task)
    else
      _ -> {:error, :send_notification?}
    end
  end
end
