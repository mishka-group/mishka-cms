defmodule MishkaDatabase.Schema.MishkaContent.BlogTagMapper do
  use Ecto.Schema

  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blog_tags_mappers" do

    belongs_to :blog_posts, MishkaDatabase.Schema.MishkaContent.Blog.Post, foreign_key: :post_id, type: :binary_id
    belongs_to :blog_tags, MishkaDatabase.Schema.MishkaContent.BlogTag, foreign_key: :tag_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:post_id, :tag_id])
    |> validate_required([:post_id, :tag_id], message: "can't be blank")
    |> MishkaDatabase.validate_binary_id(:post_id)
    |> MishkaDatabase.validate_binary_id(:tag_id)
    |> foreign_key_constraint(:post_id, message: "you can't delete it because there is a dependency")
    |> foreign_key_constraint(:tag_id, message: "you can't delete it because there is a dependency")
    |> unique_constraint(:post_id, name: :index_blog_tags_mappers_on_post_id_and_tag_id, message: "this tag has already been created.")
  end
end
