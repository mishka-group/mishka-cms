defmodule MishkaDatabase.Schema.MishkaContent.BlogTag do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blog_tags" do

    field(:title, :string, size: 200, null: false)
    field(:alias_link, :string, size: 200, null: false)
    field(:meta_keywords, :string, size: 200, null: true)
    field(:meta_description, :string, size: 164, null: true)
    field(:custom_title, :string, size: 200, null: true)
    field(:robots, ContentRobotsEnum, null: false)

    has_many :blog_tags_mappers, MishkaDatabase.Schema.MishkaContent.BlogTagMapper, foreign_key: :tag_id, on_delete: :delete_all


    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(title alias_link meta_keywords meta_description custom_title robots)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields, message: "can't be blank")
    |> validate_length(:title, max: 200, message: "maximum 200 characters")
    |> validate_length(:alias_link, max: 200, message: "maximum 200 characters")
    |> validate_length(:meta_keywords, max: 200, message: "maximum 200 characters")
    |> validate_length(:meta_description, max: 200, message: "maximum 164 characters")
    |> validate_length(:custom_title, max: 200, message: "maximum 200 characters")
    |> unique_constraint(:alias_link, name: :index_blog_tags_on_alias_link, message: "this tag alias link has already been taken.")
  end

end
