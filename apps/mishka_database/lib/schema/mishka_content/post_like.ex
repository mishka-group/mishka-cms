defmodule MishkaDatabase.Schema.MishkaContent.PostLike do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blog_likes" do
    belongs_to(:users, MishkaDatabase.Schema.MishkaUser.User,
      foreign_key: :user_id,
      type: :binary_id
    )

    belongs_to(:blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post,
      foreign_key: :post_id,
      type: :binary_id
    )

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(
    user_id post_id
  )a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields,
      message:
        MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد")
    )
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> MishkaDatabase.validate_binary_id(:post_id)
    |> foreign_key_constraint(:user_id,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"
        )
    )
    |> foreign_key_constraint(:post_id,
      message:
        MishkaTranslator.Gettext.dgettext(
          "db_schema_content",
          "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"
        )
    )
    |> unique_constraint(:post_id,
      name: :index_blog_likes_on_post_id_and_user_id,
      message:
        MishkaTranslator.Gettext.dgettext("db_schema_content", "این مطلب از قبل پسند شده است.")
    )
  end
end
