defmodule MishkaDatabase.Schema.MishkaContent.BlogTag do
  use Ecto.Schema

  require MishkaTranslator.Gettext
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
  @required_fields ~w(title alias_link robots)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> validate_length(:title, max: 200, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداکثر تعداد کاراکتر های مجاز %{number} می باشد", number: 200))
    |> validate_length(:alias_link, max: 200, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداکثر تعداد کاراکتر های مجاز %{number} می باشد", number: 200))
    |> validate_length(:meta_keywords, max: 200, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداکثر تعداد کاراکتر های مجاز %{number} می باشد", number: 200))
    |> validate_length(:meta_description, max: 200, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداکثر تعداد کاراکتر های مجاز %{number} می باشد", number: 164))
    |> validate_length(:custom_title, max: 200, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداکثر تعداد کاراکتر های مجاز %{number} می باشد", number: 200))
    |> unique_constraint(:alias_link, name: :index_blog_tags_on_alias_link, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "این لینک از قبل انتخاب شده است لطفا لینک دیگیری وارد کنید"))
  end

end
