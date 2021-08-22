defmodule MishkaDatabase.Schema.MishkaContent.BlogTagMapper do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blog_tags_mappers" do

    belongs_to :blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post, foreign_key: :post_id, type: :binary_id
    belongs_to :blog_tags, MishkaDatabase.Schema.MishkaContent.BlogTag, foreign_key: :tag_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:post_id, :tag_id])
    |> validate_required([:post_id, :tag_id], message: MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد"))
    |> MishkaDatabase.validate_binary_id(:post_id)
    |> MishkaDatabase.validate_binary_id(:tag_id)
    |> foreign_key_constraint(:post_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> foreign_key_constraint(:tag_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> unique_constraint(:post_id, name: :index_blog_tags_mappers_on_post_id_and_tag_id, message: MishkaTranslator.Gettext.dgettext("db_schema_content", "این برچسب از قبل اضافه شده است."))
  end
end
