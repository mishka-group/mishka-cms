defmodule MishkaDatabase.Repo.Migrations.BlogLinks do
  use Ecto.Migration

  def change do
    create table(:blog_links, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:short_description, :text, null: true)
      add(:status, :integer, null: false)
      add(:type, :integer, null: false)
      add(:title, :string, size: 200, null: false)
      add(:link, :string, size: 350, null: false)
      add(:short_link, :string, size: 350, null: true)

      add(:robots, :integer, null: false)

      add(:post_id, references(:blog_posts, on_delete: :nothing, type: :uuid))
    end
  end
end
