defmodule MishkaDatabase.Schema.MishkaContent.Bookmark do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "bookmarks" do

    field(:status, ContentStatusEnum, null: false, default: :active)
    field(:section, BookmarkSection, null: false, null: false)
    field(:section_id, :binary_id, primary_key: false, null: false)
    field(:extra, :map, null: true)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(status section section_id extra user_id)a
  @all_required ~w(status section section_id user_id)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> foreign_key_constraint(:user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> unique_constraint(:section, name: :index_bookmarks_on_section_and_section_id_and_user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "این بخش قبلا بوکمارک شده است"))
  end

end
