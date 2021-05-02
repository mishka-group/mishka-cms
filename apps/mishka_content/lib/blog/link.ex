defmodule MishkaContent.Blog.BlogLink do
  alias MishkaDatabase.Schema.MishkaContent.BlogLink


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogLink,
          error_atom: :blog_link,
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

  def show_by_short_link(short_link) do
    crud_get_by_field("short_link", short_link)
  end

  def links(section_id, condition: %{status: status, type: type}) do
    from(link in BlogLink,
    where: link.section_id == ^section_id,
    where: link.status == ^status,
    where: link.type == ^type)
    |> fields()
    |> MishkaDatabase.Repo.all()
  end

  def links(section_id, condition: %{status: status}) do
    from(link in BlogLink,
    where: link.section_id == ^section_id,
    where: link.status == ^status)
    |> fields()
    |> MishkaDatabase.Repo.all()
  end

  def links(section_id, condition: %{type: type}) do
    from(link in BlogLink,
    where: link.section_id == ^section_id,
    where: link.type == ^type)
    |> fields()
    |> MishkaDatabase.Repo.all()
  end

  def links(section_id) do
    from(link in BlogLink,
    where: link.section_id == ^section_id)
    |> fields()
    |> MishkaDatabase.Repo.all()
  end

  def links() do
    from(link in BlogLink)
    |> fields()
    |> MishkaDatabase.Repo.all()
  end

  defp fields(query) do
    from [link] in query,
    order_by: [desc: link.inserted_at, desc: link.id],
    select: %{
      short_description: link.short_description,
      status: link.status,
      type: link.type,
      title: link.title,
      link: link.link,
      short_link: link.short_link,
      robots: link.robots,
      section_id: link.section_id,
    }
  end
end
