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

  def edit(attrs) do
    crud_edit(attrs)
  end

  def delete(id) do
    crud_delete(id)
  end

  def show_by_id(id) do
    crud_get_record(id)
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
end
