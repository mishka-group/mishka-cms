defmodule MishkaDatabase.Schema.MishkaUser.Permission do
  use Ecto.Schema
  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    field(:value, :string)

    belongs_to :roles, MishkaDatabase.Schema.MishkaUser.Role, foreign_key: :role_id, type: :binary_id
    timestamps(type: :utc_datetime)
  end

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :role_id])
    |> validate_required([:value, :role_id], message: MishkaTranslator.Gettext.dgettext("db_schema_user", "فیلد مذکور نمی تواند خالی باشد"))
    |> MishkaDatabase.validate_binary_id(:role_id)
    |> foreign_key_constraint(:role_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> unique_constraint(:value, name: :index_permissions_on_value_and_role_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "این سطح دسترسی از قبل برای نقش مذکور اضافه شده است"))
  end

end
