defmodule MishkaDatabase.Schema.MishkaUser.User do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do

    field :full_name, :string, size: 60, null: false
    field :username, :string, size: 20, null: false
    field :email, :string, null: false
    field :status, UserStatusEnum, null: false, default: :registered

    field :password_hash, :string, null: true
    field :password, :string, virtual: true
    field :unconfirmed_email, :string, null: true

    has_many :identities, MishkaDatabase.Schema.MishkaUser.IdentityProvider, foreign_key: :user_id
    has_many :users_roles, MishkaDatabase.Schema.MishkaUser.UserRole, foreign_key: :user_id, on_delete: :delete_all
    has_many :comments, MishkaDatabase.Schema.MishkaContent.Comment, foreign_key: :user_id
    has_many :blog_likes, MishkaDatabase.Schema.MishkaContent.Comment, foreign_key: :user_id
    has_many :subscriptions, MishkaDatabase.Schema.MishkaContent.Subscription, foreign_key: :user_id
    has_many :notifs, MishkaDatabase.Schema.MishkaContent.Notif, foreign_key: :user_id
    has_many :bookmarks, MishkaDatabase.Schema.MishkaContent.Bookmark, foreign_key: :user_id

    many_to_many :roles, MishkaDatabase.Schema.MishkaUser.Role, join_through: MishkaDatabase.Schema.MishkaUser.UserRole

    timestamps(type: :utc_datetime)
  end

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_name, :username, :email, :password_hash, :password, :status, :unconfirmed_email])
    |> validate_required([:full_name, :username, :email, :status], message: MishkaTranslator.Gettext.dgettext("db_schema_user", "فیلد مذکور نمی تواند خالی باشد"))
    |> validate_length(:full_name, min: 3, max: 60, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "حداکثر تعداد کاراکتر های مجاز %{number} و حداقل %{min_number}", number: 60, min_number: 3))
    |> validate_length(:password, min: 8, max: 100, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "حداکثر تعداد کاراکتر های مجاز %{number} و حداقل %{min_number}", number: 100, min_number: 8))
    |> validate_length(:username, min: 3, max: 20, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "حداکثر تعداد کاراکتر های مجاز %{number} و حداقل %{min_number}", number: 20, min_number: 3))
    |> validate_length(:email, min: 8, max: 50, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "حداکثر تعداد کاراکتر های مجاز %{number} و حداقل %{min_number}", number: 50, min_number: 8))

    # |> SanitizeStrategy.changeset_input_validation(MishkaAuth.get_config_info(:input_validation_status))



    |> unique_constraint(:unconfirmed_email, name: :index_users_on_verified_email, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "این ایمیل از قبل در سیستم ثبت شده است."))
    |> unique_constraint(:username, name: :index_users_on_username, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "این نام کاربری از قبل در سیستم ثبت شده است."))
    |> unique_constraint(:email, name: :index_users_on_email, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "این ایمیل از قبل در سیستم ثبت شده است."))
    |> hash_password
  end

  def login_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password], message: MishkaTranslator.Gettext.dgettext("db_schema_user", "فیلد مذکور نمی تواند خالی باشد"))
    |> validate_length(:password, min: 8, max: 100, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "حداکثر تعداد کاراکتر های مجاز %{number} و حداقل %{min_number}", number: 100, min_number: 8))
    |> validate_length(:email, min: 8, max: 50, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "حداکثر تعداد کاراکتر های مجاز %{number} و حداقل %{min_number}", number: 50, min_number: 8))
  end


  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
      _ -> changeset
    end
  end
end
