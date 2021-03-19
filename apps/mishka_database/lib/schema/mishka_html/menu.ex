defmodule MishkaDatabase.Schema.MishkaHtml.Menue do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "menues" do
    field :title, :string, size: 200, null: false
    field :short_description, :string, size: 164, null: false
    field :status, ContentStatusEnum, null: false, default: :active
    field :image, :string, size: 200, null: false
    field :place, :integer, null: false
    field :sub, :string, null: true, default: nil
    field :alias_link, :string, size: 200, null: false
    field :meta_keywords, :string, size: 200, null: false
    field :meta_description, :string, size: 164, null: false

    # type of menu and which system with extra info


    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(title short_description status place sub)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields, message: "can't be blank")
    |> validate_length(:title, min: 10, max: 200, message: "minimum 10 characters and maximum 200 characters")
    |> validate_length(:short_description, min: 20, max: 350, message: "minimum 20 characters and maximum 350 characters")
    |> validate_length(:alias_link, min: 5, max: 200, message: "minimum 5 characters and maximum 200 characters")
    |> validate_length(:meta_keywords, min: 8, max: 200, message: "minimum 8 characters and maximum 200 characters")
    |> validate_length(:meta_description, min: 8, max: 164, message: "minimum 8 characters and maximum 164 characters")
  end

end
