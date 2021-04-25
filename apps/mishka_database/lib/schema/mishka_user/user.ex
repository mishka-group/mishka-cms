defmodule MishkaDatabase.Schema.MishkaUser.User do
  use Ecto.Schema


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

    many_to_many :roles, MishkaDatabase.Schema.MishkaUser.Role, join_through: MishkaDatabase.Schema.MishkaUser.UserRole

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_name, :username, :email, :password_hash, :password, :status, :unconfirmed_email])
    |> validate_required([:full_name, :username, :email, :status], message: "can't be blank")
    |> validate_length(:full_name, min: 3, max: 60, message: "minimum 3 characters and maximum 20 characters")
    |> validate_length(:password, min: 8, max: 100, message: "minimum 8 characters and maximum 100 characters")
    |> validate_length(:username, min: 3, max: 20, message: "minimum 3 characters and maximum 20 characters")
    |> validate_length(:email, min: 8, max: 50, message: "minimum 8 characters and maximum 50 characters")

    # |> SanitizeStrategy.changeset_input_validation(MishkaAuth.get_config_info(:input_validation_status))



    |> unique_constraint(:unconfirmed_email, name: :index_users_on_verified_email, message: "this email has already been taken.")
    |> unique_constraint(:username, name: :index_users_on_username, message: "this username has already been taken.")
    |> unique_constraint(:email, name: :index_users_on_email, message: "this email has already been taken.")
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
      _ -> changeset
    end
  end
end
