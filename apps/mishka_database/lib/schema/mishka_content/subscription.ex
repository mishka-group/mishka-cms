defmodule MishkaDatabase.Schema.MishkaContent.Subscription do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscriptions" do

    field(:status, ContentStatusEnum, null: false)
    field(:section, SubscriptionSection, null: false, null: false)
    field(:section_id, :binary_id, primary_key: false, null: false)
    field(:expire_time, :utc_datetime, null: true)
    field(:extra, :map, null: true)

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(status section section_id expire_time extra user_id)a
  @all_required ~w(status section section_id user_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_required, message: "can't be blank")
    |> unique_constraint(:section, name: :index_subscriptions_on_section_and_section_id_and_user_id, message: "you have already been subscriped.")
  end

end
