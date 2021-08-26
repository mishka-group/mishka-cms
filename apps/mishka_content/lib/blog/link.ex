defmodule MishkaContent.Blog.BlogLink do
  alias MishkaDatabase.Schema.MishkaContent.BlogLink


  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogLink,
          error_atom: :blog_link,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :blog_link
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_link")
  end

  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:blog_link)
  end

  @spec create(record_input(), allowed_fields :: list()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
    |> notify_subscribers(:blog_link)
  end

  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:blog_link)
  end

  @spec edit(record_input(), allowed_fields :: list()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
    |> notify_subscribers(:blog_link)
  end

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:blog_link)
  end

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}
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
    from(link in BlogLink) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  def links(filters: filters) do
    from(link in BlogLink) |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.all()
  rescue
    Ecto.Query.CastError -> []
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
