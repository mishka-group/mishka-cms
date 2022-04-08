defmodule MishkaContent.Blog.BlogLink do
  alias MishkaDatabase.Schema.MishkaContent.BlogLink


  import Ecto.Query
  use MishkaDeveloperTools.DB.CRUD,
          module: BlogLink,
          error_atom: :blog_link,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :blog_link
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDeveloperTools.DB.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_link")
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:blog_link)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:blog_link)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:blog_link)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:blog_link)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:blog_link)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec show_by_short_link(String.t()) ::
          {:error, :get_record_by_field, error_tag()} | {:ok, :get_record_by_field, error_tag(), repo_data()}
  def show_by_short_link(short_link) do
    crud_get_by_field("short_link", short_link)
  end

  @spec links([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: any
  def links(conditions: {page, page_size}, filters: filters) do
    from(link in BlogLink)
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("blog_link", "read", db_error)
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  def links(filters: filters) do
    from(link in BlogLink) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.all()
  rescue
    db_error ->
      MishkaContent.db_content_activity_error("blog_link", "read", db_error)
      []
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from link in query, where: field(link, ^key) == ^value
    end)
  end

  defp fields(query) do
    from [link] in query,
    order_by: [desc: link.inserted_at, desc: link.id],
    select: %{
      id: link.id,
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

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :blog_link, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_link", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: BlogLink.__schema__(:fields)
  def allowed_fields(:string), do: BlogLink.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
