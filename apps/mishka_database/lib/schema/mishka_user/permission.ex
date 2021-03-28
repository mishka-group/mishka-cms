defmodule MishkaDatabase.Schema.MishkaUser.Permission do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    field :title, :string, size: 100, null: false
    field :tag, :string, size: 100, null: false

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :tag])
    |> validate_required([:title, :tag], message: "can't be blank")
  end

end
