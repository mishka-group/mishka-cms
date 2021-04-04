defmodule MishkaDatabase.Schema.MishkaContent.Activity do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activities" do

    field :type, :string, size: 100, null: false
    field :section, :string, size: 100, null: false
    field :priority, ContentPriorityEnum, null: false
    field :status, ActivitiesStatusEnum, null: false
    field :extra, :map, null: true

    # user_id
    # action like {:delete, :edit, etc...}
    # type like {:blog, :content_category, :social, :email}
    # status like {:error, :info, :warning, :report}

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(type section priority status extra)a
  @all_required ~w(type section priority status)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: "can't be blank")
    |> validate_length(:type, max: 100, message: "maximum 100 characters")
    |> validate_length(:section, max: 100, message: "maximum 100 characters")
  end

end
