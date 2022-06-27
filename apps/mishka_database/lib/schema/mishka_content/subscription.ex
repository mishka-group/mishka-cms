defmodule MishkaDatabase.Schema.MishkaContent.Subscription do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscriptions" do
    field(:status, ContentStatusEnum, default: :active)
    field(:section, SubscriptionSection)
    field(:section_id, :binary_id, primary_key: false)
    field(:expire_time, :utc_datetime)
    field(:extra, :map)

    belongs_to(:users, MishkaDatabase.Schema.MishkaUser.User,
      foreign_key: :user_id,
      type: :binary_id
    )

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(status section section_id expire_time extra user_id)a
  @all_required ~w(status section section_id user_id)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required,
      message:
        MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد")
    )
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> foreign_key_constraint(:user_id,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"
        )
    )
    |> unique_constraint(:section,
      name: :index_subscriptions_on_section_and_section_id_and_user_id,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "شما از قبل در این بخش مشترک شده اید."
        )
    )
  end
end
