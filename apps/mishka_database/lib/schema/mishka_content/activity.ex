defmodule MishkaDatabase.Schema.MishkaContent.Activity do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "content_activities" do

    field :title, :string, size: 200, null: false
    field :description, :string, null: false
    field :priority, ContentPriorityEnum, null: false, default: :none

    # user_id
    # action like {:delete, :edit, etc...}
    # type like {:blog, :content_category, :social, :email}
    # status like {:error, :info, :warning, :report}

    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(title description)a

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
