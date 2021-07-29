defmodule MishkaDatabase.Schema.MishkaContent.Comment do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "comments" do

    field(:description, :string, null: false)
    field(:status, ContentStatusEnum, null: false, default: :active)
    field(:priority, ContentPriorityEnum, null: false, default: :none)
    field(:section, CommentSection, null: false, default: :blog_post)
    field(:section_id, :binary_id, null: false)
    field(:sub, :binary_id, null: true)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    has_many :comments_likes, MishkaDatabase.Schema.MishkaContent.CommentLike, foreign_key: :comment_id

    timestamps(type: :utc_datetime)
  end


  @all_fields ~w(
    description status priority sub user_id section_id section
  )a

  @all_required ~w(
    description status priority user_id section_id section
  )a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: "can't be blank")
    |> validate_length(:description, min: 5, max: 2000, message: "حداکثر مجاز ارسال نظر 2000 کاراکتر می باشد و حداقل نیز ۵ کاراکتر")
    |> MishkaDatabase.validate_binary_id(:section_id)
    |> MishkaDatabase.validate_binary_id(:sub)
    |> foreign_key_constraint(:users, message: "this comment has already been taken or you can't delete it because there is a dependency")
  end
end
