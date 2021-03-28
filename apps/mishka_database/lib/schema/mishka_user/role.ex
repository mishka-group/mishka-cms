defmodule MishkaDatabase.Schema.MishkaUser.Role do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "roles" do
    field :title, :string, size: 100, null: false
    field :permission, :string, null: false

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :permission])
    |> validate_required([:title, :permission], message: "can't be blank")
  end

end
