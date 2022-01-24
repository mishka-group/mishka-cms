defmodule MishkaDatabase.Schema.MishkaInstaller.Plugin do
  use Ecto.Schema

  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "plugins" do

    field :name, :string, null: false
    field :event, :string, null: false
    field :priority, :integer, null: false
    field :status, PluginStatusEnum, null: false, default: :started
    field :depend_type, PluginDependTypeEnum, null: false, default: :soft
    field :depends, {:array, :string}, null: true

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(name event priority status depend_type depends)a
  @required_fields ~w(name event priority status depend_type)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@required_fields, message: MishkaTranslator.Gettext.dgettext("db_schema_installer", "فیلد مذکور نمی تواند خالی باشد"))
    |> unique_constraint(:name, name: :index_identities_on_provider_uid_and_identity_provider, message: MishkaTranslator.Gettext.dgettext("db_schema_user", "هر پلاگین می تواند یک اسم یکتا داشته باشد"))
  end

end
