defmodule MishkaDatabase.Schema.MishkaContent.BlogLink do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blog_links" do

    field(:short_description, :string, null: true)
    field(:status, ContentStatusEnum, null: false)
    field(:type, BlogLinkType, null: false)
    field(:title, :string, size: 200, null: false)
    field(:link, :string, size: 350, null: false)
    field(:short_link, :string, size: 350, null: true)

    field(:robots, ContentRobotsEnum, null: false)

    field(:section_id, :binary_id, null: false)

    timestamps(type: :utc_datetime)
  end


  @all_fields ~w(
    short_description status type title link short_link robots section_id
  )a

  @all_required ~w(
    short_description status type title link robots section_id
  )a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> unique_constraint(:short_link, name: :index_blog_links_on_short_link, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "این لینک کوتاه از قبل انتخاب شده است. لطفا لینک دیگری را وارد کنید."))
  end

end
