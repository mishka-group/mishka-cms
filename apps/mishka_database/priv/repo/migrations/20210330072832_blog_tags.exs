defmodule MishkaDatabase.Repo.Migrations.BlogTags do
  use Ecto.Migration

  def change do
    create table(:blog_tags, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string, size: 200, null: false)


      add(:alias_link, :string, size: 200, null: false)
      add(:meta_keywords, :string, size: 200, null: true)
      add(:meta_description, :string, size: 164, null: true)
      add(:custom_title, :string, size: 200, null: true)
      add(:robots, :integer, null: false)

      timestamps()
    end
    create(
      index(:blog_tags, [:alias_link],
        # concurrently: true,
        name: :index_blog_tags_on_alias_link,
        unique: true
      )
    )
  end
end
