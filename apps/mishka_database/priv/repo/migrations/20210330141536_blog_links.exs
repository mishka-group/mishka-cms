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

      add(:section_id, :uuid, primary_key: false, null: false)

      add(:robots, :integer, null: false)

      timestamps()
    end
    create(
      index(:blog_links, [:short_link],
        name: :index_blog_links_on_short_link,
        unique: true
      )
    )
  end
end
