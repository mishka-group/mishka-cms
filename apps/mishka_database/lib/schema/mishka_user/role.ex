defmodule MishkaDatabase.Schema.MishkaUser.Role do
  use Ecto.Schema
  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "roles" do
    field :name, :string
    field :display_name, :string

    has_many :users_roles, MishkaDatabase.Schema.MishkaUser.UserRole, foreign_key: :role_id, on_delete: :delete_all
    has_many :permissions, MishkaDatabase.Schema.MishkaUser.Permission, foreign_key: :role_id, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :display_name])
    |> validate_required([:name, :display_name], message: MishkaTranslator.Gettext.dgettext("db_schema_user", "فیلد مذکور نمی تواند خالی باشد"))
  end

end
