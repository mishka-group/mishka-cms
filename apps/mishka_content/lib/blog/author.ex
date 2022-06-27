defmodule MishkaContent.Blog.Author do
  alias MishkaDatabase.Schema.MishkaContent.BlogAuthor

  import Ecto.Query

  use MishkaDeveloperTools.DB.CRUD,
    module: BlogAuthor,
    error_atom: :blog_author,
    repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t()
  @type record_input() :: map()
  @type error_tag() :: :blog_author
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDeveloperTools.DB.CRUD

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :delete, :blog_author | :forced_to_delete | :get_record_by_id | :uuid,
           :blog_author | :not_found | Ecto.Changeset.t()}
          | {:ok, :delete, :blog_author, %{optional(atom) => any}}
  def delete(user_id, post_id) do
    from(author in BlogAuthor, where: author.user_id == ^user_id and author.post_id == ^post_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :blog_author, :not_found}
      author_record -> delete(author_record.id)
    end
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("blog_author", "delete", db_error)
      {:error, :delete, :blog_author, :not_found}
  end

  @spec authors(data_uuid()) :: list()
  def authors(post_id) do
    from(author in BlogAuthor,
      where: author.post_id == ^post_id,
      join: user in assoc(author, :users),
      select: %{
        id: author.id,
        post_id: author.post_id,
        inserted_at: author.inserted_at,
        updated_at: author.updated_at,
        user_id: user.id,
        user_full_name: user.full_name
      }
    )
    |> MishkaDatabase.Repo.all()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("blog_author", "read", db_error)
      []
  end

  @spec authors :: Ecto.Query.t()
  def authors() do
    from(author in BlogAuthor,
      join: user in assoc(author, :users),
      select: %{
        id: author.id,
        post_id: author.post_id,
        user_id: user.id,
        user_full_name: user.full_name
      }
    )
  end

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: BlogAuthor.__schema__(:fields)
  def allowed_fields(:string), do: BlogAuthor.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
