defmodule MishkaDatabase.Schema.MishkaContent.Activity do
  use Ecto.Schema
  require MishkaTranslator.Gettext

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activities" do
    field(:type, ActivitiesTypeEnum)
    field(:section, ActivitiesSection)
    field(:section_id, :binary_id, primary_key: false)
    field(:priority, ContentPriorityEnum)
    field(:status, ActivitiesStatusEnum)
    field(:action, ActivitiesAction)
    field(:extra, :map)

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(type section section_id priority status action extra)a
  @all_required ~w(type section priority status action)a

  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required,
      message:
        MishkaTranslator.Gettext.dgettext("db_schema_content", "فیلد مذکور نمی تواند خالی باشد")
    )
    |> MishkaDatabase.validate_binary_id(:section_id)
  end
end
