defmodule MishkaDatabase.Schema.MishkaContent.Notif do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifs" do

    field(:status, ContentStatusEnum, null: false)
    field(:section, NotifSection, size: 100, null: false)
    field(:section_id, :binary_id, primary_key: false, null: true)
    field(:short_description, :string, size: 350, null: true)
    field(:expire_time, :utc_datetime, null: true)
    field(:extra, :map, null: true)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(status section section_id short_description expire_time extra user_id)a
  @all_required ~w(status section)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: "can't be blank")
    |> foreign_key_constraint(:users, message: "you can't delete it because there is a dependency")
  end

end
