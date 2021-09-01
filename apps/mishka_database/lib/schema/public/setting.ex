defmodule MishkaDatabase.Schema.Public.Setting do
  use Ecto.Schema
  require MishkaTranslator.Gettext
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "settings" do

    field(:section, SettingSectionEnum, null: false)
    field(:configs, :map, null: true)


    timestamps(type: :utc_datetime)
  end

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:section, :configs])
    |> validate_required([:section, :configs], message: MishkaTranslator.Gettext.dgettext("db_schema_public", "فیلد مذکور نمی تواند خالی باشد"))
    |> unique_constraint(:section, name: :index_section_on_settings, message: MishkaTranslator.Gettext.dgettext("db_schema_public", "برای این بخش قبلا تنظیمات وارد شده است."))
  end

end
