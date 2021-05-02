defmodule MishkaContent.Blog.TagMapper  do
  alias MishkaDatabase.Schema.MishkaContent.BlogTagMapper

  use MishkaDatabase.CRUD,
          module: BlogTagMapper,
          error_atom: :blog_tag_mapper,
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
end
