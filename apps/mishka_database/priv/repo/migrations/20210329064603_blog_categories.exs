defmodule MishkaDatabase.Repo.Migrations.BlogCategories do
  use Ecto.Migration

  def change do
    create table(:blog_categories, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      # Category basic info
      add(:title, :string, size: 200, null: false)
      add(:short_description, :string, size: 350, null: false)
      add(:main_image, :string, size: 200, null: false)
      add(:header_image, :string, size: 200, null: true)
      add(:description, :text, null: false)
      add(:status, :integer, null: false) #Enum
      add(:sub, :uuid, primary_key: false, null: true)

      # Seo config
      add(:alias_link, :string, size: 200, null: false)
      add(:meta_keywords, :string, size: 200, null: true)
      add(:meta_description, :string, size: 164, null: true)
      add(:custom_title, :string, size: 200, null: true)
      add(:robots, :integer, null: false) #Enum


      # Extra config
      add(:category_visibility, :integer, null: false) #Enum
      add(:allow_commenting, :boolean, null: false)
      add(:allow_liking, :boolean, null: false)
      add(:allow_printing, :boolean, null: false)
      add(:allow_reporting, :boolean, null: false)
      add(:allow_social_sharing, :boolean, null: false)
      add(:allow_subscription, :boolean, null: false)
      add(:allow_bookmarking, :boolean, null: false)
      add(:allow_notif, :boolean, null: false)

      add(:show_hits, :boolean, null: false)
      add(:show_time, :boolean, null: false)
      add(:show_authors, :boolean, null: false)
      add(:show_category, :boolean, null: false)
      add(:show_links, :boolean, null: false)
      add(:show_location, :boolean, null: false)

      timestamps()
    end
    create(
      index(:blog_categories, [:alias_link],
        # concurrently: true,
        name: :index_blog_categories_on_alias_link,
        unique: true
      )
    )
  end
end
