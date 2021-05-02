defmodule MishkaDatabase.Schema.MishkaContent.BlogAuthor do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blog_authors" do

    belongs_to :blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post, foreign_key: :post_id, type: :binary_id
    belongs_to :users, MishkaDatabase.Schema.MishkaUser.User, foreign_key: :user_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:post_id, :user_id])
    |> validate_required([:user_id, :post_id], message: "can't be blank")
    |> foreign_key_constraint(:post_id, message: "you can't delete it because there is a dependency")
    |> foreign_key_constraint(:user_id, message: "you can't delete it because there is a dependency")
    |> unique_constraint(:post_id, name: :index_blog_authors_on_post_id_and_user_id, message: "this author has already been created.")
  end
end
