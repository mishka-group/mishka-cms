defmodule MishkaDatabase.Repo.Migrations.CommentsLikes do
  use Ecto.Migration

  def change do
    create table(:comments_likes, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      add(:comment_id, references(:comments, on_delete: :nothing, type: :uuid))


      timestamps()
    end
    create(
      index(:comments_likes, [:user_id, :comment_id],
        name: :index_comments_on_likes,
        unique: true
      )
    )
  end
end
