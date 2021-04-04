defmodule MishkaDatabase.Repo.Migrations.BlogComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      # comment basic info
      add(:description, :text, null: false)
      add(:status, :integer, null: false)
      add(:priority, :integer, null: false)
      add(:sub, :uuid, primary_key: false)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      add(:post_id, references(:blog_posts, on_delete: :nothing, type: :uuid))
      timestamps()
    end

  end
end
