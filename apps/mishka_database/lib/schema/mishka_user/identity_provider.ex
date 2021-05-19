defmodule MishkaDatabase.Schema.MishkaUser.IdentityProvider do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "identities" do

    field :provider_uid, :string, null: true
    field :token, :string, null: true
    field :identity_provider, UserIdentityProviderEnum, null: false, default: :self

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(provider_uid token user_id identity_provider)a
  @required_fields ~w(user_id identity_provider)a
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields, message: "can't be blank")
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> foreign_key_constraint(:user_id, message: "this username has already been taken or you can't delete it because there is a dependency")
    |> unique_constraint(:provider_uid, name: :index_identities_on_provider_uid_and_identity_provider, message: "this account has already been taken.")
    |> unique_constraint(:identity_provider, name: :index_identities_on_user_id_and_identity_provider, message: "this account has already been taken.")
  end

end
