defmodule MishkaDatabase.Schema.MishkaUser.UserToken do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "user_tokens" do
    field(:token, :string)
    field(:type, UserTokenTypeEnum)
    field(:expire_time, :utc_datetime)
    field(:extra, :map)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(id token type expire_time extra user_id)a
  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "فیلد مذکور نمی تواند خالی باشد"))
    |> foreign_key_constraint(:user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> unique_constraint(:token, name: :index_token_on_user_tokens, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "این ایمیل از قبل در سیستم ثبت شده است."))
  end
end
