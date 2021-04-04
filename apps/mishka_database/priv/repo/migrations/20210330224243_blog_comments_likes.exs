defmodule MishkaDatabase.Repo.Migrations.BlogCommentsLikes do
  use Ecto.Migration

  def change do
    create table(:blog_comments_likes, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:post_id, references(:blog_posts, on_delete: :nothing, type: :uuid))
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      add(:comment_id, references(:comments, on_delete: :nothing, type: :uuid))


      timestamps()
    end
    create(
      index(:blog_comments_likes, [:post_id, :user_id, :comment_id],
        name: :index_blog_on_comments_likes,
        unique: true
      )
    )
  end
end
