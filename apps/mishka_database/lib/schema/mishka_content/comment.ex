defmodule MishkaDatabase.Schema.MishkaContent.Comment do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "comments" do
    field(:description, :string)
    field(:status, ContentStatusEnum, default: :active)
    field(:priority, ContentPriorityEnum, default: :none)
    field(:section, CommentSection, default: :blog_post)
    field(:section_id, :binary_id)
    field(:sub, :binary_id)

    belongs_to(:users, MishkaDatabase.Schema.MishkaUser.User,
      foreign_key: :user_id,
      type: :binary_id
    )

    has_many(:comments_likes, MishkaDatabase.Schema.MishkaContent.CommentLike,
      foreign_key: :comment_id
    )

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(
    description status priority sub user_id section_id section
  )a

  @all_required ~w(
    description status priority user_id section_id section
  )a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required,
      message:
        MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد")
    )
    |> validate_length(:description,
      min: 5,
      max: 2000,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "حداکثر تعداد کاراکتر های مجاز %{number} می باشد",
          number: 200
        )
    )
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> MishkaDatabase.validate_binary_id(:sub)
    |> foreign_key_constraint(:user_id,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"
        )
    )
  end
end
