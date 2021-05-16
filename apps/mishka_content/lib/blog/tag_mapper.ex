defmodule MishkaContent.Blog.TagMapper  do
  alias MishkaDatabase.Schema.MishkaContent.BlogTagMapper

  import Ecto.Query
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

  def delete(post_id, tag_id) do
    from(tag in BlogTagMapper, where: tag.post_id == ^post_id and tag.tag_id == ^tag_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :blog_tag_mapper, :not_found}
      tag_record -> delete(tag_record.id)
    end
  end

  def show_by_id(id) do
    crud_get_record(id)
  end

  def allowed_fields(:atom), do: BlogTagMapper.__schema__(:fields)
  def allowed_fields(:string), do: BlogTagMapper.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
