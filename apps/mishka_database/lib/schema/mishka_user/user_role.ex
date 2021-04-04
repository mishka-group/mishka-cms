defmodule MishkaDatabase.Schema.MishkaUser.UserRole do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users_roles" do

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    belongs_to :roles, MishkaDatabase.Schema.MishkaUser.Role, foreign_key: :role_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id], message: "can't be blank")
    |> foreign_key_constraint(:user_id, message: "this username has already been taken or you can't delete it because there is a dependency")
    |> foreign_key_constraint(:role_id, message: "this username has already been taken or you can't delete it because there is a dependency")
    |> unique_constraint(:role_id, name: :index_users_roles_on_role_id_and_user_id, message: "this account has already been taken.")
  end
end
