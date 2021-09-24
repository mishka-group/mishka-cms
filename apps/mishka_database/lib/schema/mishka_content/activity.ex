defmodule MishkaDatabase.Schema.MishkaContent.Activity do
  use Ecto.Schema
  require MishkaTranslator.Gettext

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activities" do

    field(:type, ActivitiesTypeEnum, null: false)
    field(:section, ActivitiesSection, null: false)
    field(:section_id, :binary_id, primary_key: false, null: true)
    field(:priority, ContentPriorityEnum, null: false)
    field(:status, ActivitiesStatusEnum, null: false)
    field(:action, ActivitiesAction, null: false)
    field(:extra, :map, null: true)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(type section section_id priority status action extra user_id)a
  @all_required ~w(type section priority status action)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> foreign_key_constraint(:user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> MishkaDatabase.validate_binary_id(:section_id)
  end

end
