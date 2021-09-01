defmodule MishkaDatabase.Schema.MishkaUser.UserRole do
  use Ecto.Schema
  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users_roles" do

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    belongs_to :roles, MishkaDatabase.Schema.MishkaUser.Role, foreign_key: :role_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id], message: MishkaTranslator.Gettext.dgettext("db_schema_user", "فیلد مذکور نمی تواند خالی باشد"))
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> MishkaDatabase.validate_binary_id(:role_id)
    |> foreign_key_constraint(:user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> foreign_key_constraint(:role_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "ممکن است فیلد مذکور اشتباه باشد یا برای حذف آن اگر اقدام می کنید برای آن وابستگی وجود داشته باشد"))
    |> unique_constraint(:role_id, name: :index_users_roles_on_role_id_and_user_id, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "این حساب کربری از قبل در سیستم ثبت شده است."))
  end
end
