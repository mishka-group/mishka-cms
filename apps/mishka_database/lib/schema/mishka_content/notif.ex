defmodule MishkaDatabase.Schema.MishkaContent.Notif do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifs" do

    field(:status, ContentStatusEnum, null: false)
    field(:section, NotifSection, null: false)
    field(:section_id, :binary_id, primary_key: false, null: true)
    field(:type, NotifType, null: false)
    field(:target, NotifTarget, null: false)
    field(:short_description, :string, size: 350, null: true)
    field(:expire_time, :utc_datetime, null: true)
    field(:extra, :map, null: true)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    has_many :user_notif_statuses, MishkaDatabase.Schema.MishkaContent.UserNotifStatus, foreign_key: :notif_id

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(status section section_id short_description expire_time extra user_id type target)a
  @all_required ~w(status section type target)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> foreign_key_constraint(:user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
  end

end
