defmodule MishkaDatabase.Schema.MishkaContent.Notif do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifs" do

    field(:status, ContentStatusEnum, default: :active)
    field(:section, NotifSection)
    field(:type, NotifType)
    field(:target, NotifTarget)
    field(:section_id, :binary_id, primary_key: false)
    field(:title, :string)
    field(:description, :string)
    field(:expire_time, :utc_datetime)
    field(:extra, :map)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    has_many :user_notif_statuses, MishkaDatabase.Schema.MishkaContent.UserNotifStatus, foreign_key: :notif_id

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(status section section_id title description expire_time extra user_id type target)a
  @all_required ~w(status section type target title description)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> validate_length(:title, max: 350, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداکثر تعداد کاراکتر های مجاز %{number} می باشد", number: 350))
    |> validate_length(:description, min: 10, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "حداقل تعداد کاراکتر های مجاز %{number} می باشد", number: 10))
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> foreign_key_constraint(:user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
  end

end
