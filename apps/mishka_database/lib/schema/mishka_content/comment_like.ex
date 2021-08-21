defmodule MishkaDatabase.Schema.MishkaContent.CommentLike do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "comments_likes" do

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    belongs_to :comments, MishkaDatabase.Schema.MishkaContent.Comment, foreign_key: :comment_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  @all_fields ~w(
    user_id comment_id
  )a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields, message: "can't be blank")
    |> MishkaDatabase.validate_binary_id(:user_id)
    |> MishkaDatabase.validate_binary_id(:comment_id)
    |> foreign_key_constraint(:user_id, message: "you can't delete it because there is a dependency")
    |> foreign_key_constraint(:comment_id, message: "you can't delete it because there is a dependency")
    |> unique_constraint(:user_id, name: :index_comments_on_likes, message: "this comment has already been liked.")
  end

end
