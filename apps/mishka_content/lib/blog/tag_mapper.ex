defmodule MishkaContent.Blog.TagMapper  do
  alias MishkaDatabase.Schema.MishkaContent.BlogTagMapper

  import Ecto.Query
  use MishkaDatabase.CRUD,
          module: BlogTagMapper,
          error_atom: :blog_tag_mapper,
          repo: MishkaDatabase.Repo

  @type data_uuid() :: Ecto.UUID.t
  @type record_input() :: map()
  @type error_tag() :: :blog_tag_mapper
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @behaviour MishkaDatabase.CRUD


  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "blog_tag_mapper")
  end

  @spec create(record_input()) ::
  {:error, :add, error_tag(), repo_error()} | {:ok, :add, error_tag(), repo_data()}
  def create(attrs) do
    crud_add(attrs)
    |> notify_subscribers(:blog_tag_mapper)
  end

  @spec edit(record_input()) ::
  {:error, :edit, :uuid, error_tag()} |
  {:error, :edit, :get_record_by_id, error_tag()} |
  {:error, :edit, error_tag(), repo_error()} | {:ok, :edit, error_tag(), repo_data()}
  def edit(attrs) do
    crud_edit(attrs)
    |> notify_subscribers(:blog_tag_mapper)
  end

  @spec delete(data_uuid()) ::
  {:error, :delete, :uuid, error_tag()} |
  {:error, :delete, :get_record_by_id, error_tag()} |
  {:error, :delete, :forced_to_delete, error_tag()} |
  {:error, :delete, error_tag(), repo_error()} | {:ok, :delete, error_tag(), repo_data()}
  def delete(id) do
    crud_delete(id)
    |> notify_subscribers(:blog_tag_mapper)
  end

  @spec delete(data_uuid(), data_uuid()) ::
          {:error, :delete, :blog_tag_mapper | :forced_to_delete | :get_record_by_id | :uuid,
           :blog_tag_mapper | :not_found | Ecto.Changeset.t()}
          | {:ok, :delete, :blog_tag_mapper, %{optional(atom) => any}}
  def delete(post_id, tag_id) do
    from(tag in BlogTagMapper, where: tag.post_id == ^post_id and tag.tag_id == ^tag_id)
    |> MishkaDatabase.Repo.one()
    |> case do
      nil -> {:error, :delete, :blog_tag_mapper, :not_found}
      tag_record -> delete(tag_record.id)
    end
  rescue
    Ecto.Query.CastError -> {:error, :delete, :blog_tag_mapper, :not_found}
  end

  @spec show_by_id(data_uuid()) ::
          {:error, :get_record_by_id, error_tag()} | {:ok, :get_record_by_id, error_tag(), repo_data()}
  def show_by_id(id) do
    crud_get_record(id)
  end

  @spec tags([{:conditions, {integer() | String.t(), integer() | String.t()}} | {:filters, map()}, ...]) :: Scrivener.Page.t()
  def tags(conditions: {page, page_size}, filters: filters) do
    from(tag_mapper in BlogTagMapper,
    join: post in assoc(tag_mapper, :blog_posts),
    join: tag in assoc(tag_mapper, :blog_tags))
    |> convert_filters_to_where(filters)
    |> fields()
    |> MishkaDatabase.Repo.paginate(page: page, page_size: page_size)
  rescue
    Ecto.Query.CastError ->
      %Scrivener.Page{entries: [], page_number: 1, page_size: page_size, total_entries: 0,total_pages: 1}
  end

  defp convert_filters_to_where(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      from tag in query, where: field(tag, ^key) == ^value
    end)
  end

  def fields(query) do
    from([tag_mapper, post, tag] in query,
    select: %{
      id: tag_mapper.id,
      post_id: post.id,
      post_title: post.title,
      tag_id: tag.id,
      tag_title: tag.title,
    })
  end

  @spec notify_subscribers(tuple(), atom() | String.t()) :: tuple() | map()
  def notify_subscribers({:ok, _, :blog_tag_mapper, repo_data} = params, type_send) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "blog_tag_mapper", {type_send, :ok, repo_data})
    params
  end

  def notify_subscribers(params, _), do: params

  @spec allowed_fields(:atom | :string) :: nil | list
  def allowed_fields(:atom), do: BlogTagMapper.__schema__(:fields)
  def allowed_fields(:string), do: BlogTagMapper.__schema__(:fields) |> Enum.map(&Atom.to_string/1)
end
