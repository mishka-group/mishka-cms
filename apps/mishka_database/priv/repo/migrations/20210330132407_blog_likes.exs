defmodule MishkaDatabase.Repo.Migrations.BlogLikes do
  use Ecto.Migration

  def change do
    create table(:blog_likes, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:post_id, references(:blog_posts, on_delete: :nothing, type: :uuid))
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))

      timestamps()
    end
    create(
      index(:blog_likes, [:post_id, :user_id],
        name: :index_blog_likes_on_post_id_and_user_id,
        unique: true
      )
    )
  end
end
