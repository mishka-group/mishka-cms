defmodule MishkaDatabase.Schema.MishkaContent.BlogLike do
  use Ecto.Schema


  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id


  schema "blog_likes" do

    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id
    belongs_to :blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post , foreign_key: :post_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  @all_fields ~w(
    user_id post_id
  )a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields, message: "can't be blank")
    |> foreign_key_constraint(:users, message: "you can't delete it because there is a dependency")
    |> foreign_key_constraint(:blog_posts, message: "you can't delete it because there is a dependency")
    |> unique_constraint(:post_id, name: :index_blog_likes_on_post_id_and_user_id, message: "this post has already been liked.")
  end

end
