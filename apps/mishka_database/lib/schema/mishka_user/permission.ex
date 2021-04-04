defmodule MishkaDatabase.Schema.MishkaUser.Permission do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    field(:value, :string, null: false)

    belongs_to :roles, MishkaDatabase.Schema.MishkaUser.Role, foreign_key: :role_id, type: :binary_id
    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :role_id])
    |> validate_required([:value, :role_id], message: "can't be blank")
    |> foreign_key_constraint(:role_id, message: "this role has already been taken or you can't delete it because there is a dependency")
    |> unique_constraint(:value, name: :index_permissions_on_value_and_role_id, message: "this role has already been taken.")
  end

end
