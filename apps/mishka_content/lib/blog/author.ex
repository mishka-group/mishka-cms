defmodule MishkaContent.Blog.Author do

  alias MishkaDatabase.Schema.MishkaContent.BlogAuthor

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogAuthor,
          error_atom: :blog_author,
          repo: MishkaDatabase.Repo

  @behaviour MishkaDatabase.CRUD


  def create(attrs) do
    crud_add(attrs)
  end

  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  def edit(attrs) do
    crud_edit(attrs)
  end

  def delete(id) do
    crud_delete(id)
  end

  def delete(user_id, post_id) do
    from(author in BlogAuthor, where: author.user_id == ^user_id and author.post_id == ^post_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :blog_author, :not_found}
      author_record -> delete(author_record.id)
    end
  rescue
    Ecto.Query.CastError -> {:error, :delete, :blog_author, :not_found}
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def authors(post_id) do
    from(author in BlogAuthor,
    where: author.post_id == ^post_id,
    join: user in assoc(author, :users),
    select: %{
      id: author.id,
      post_id: author.post_id,
      user_id: user.id,
      user_full_name: user.full_name
    })
    |> MishkaDatabase.Repo.all()
  rescue
    Ecto.Query.CastError -> []
  end

  def authors() do
    from(author in BlogAuthor,
    join: user in assoc(author, :users),
    select: %{
      id: author.id,
      post_id: author.post_id,
      user_id: user.id,
      user_full_name: user.full_name
    })
  end

  def allowed_fields(:atom), do: BlogAuthor.__schema__(:fields)
  def allowed_fields(:string), do: BlogAuthor.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
