defmodule MishkaDatabase.Repo.Migrations.BlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      # post basic info
      add(:title, :string, size: 200, null: false)
      add(:short_description, :string, size: 350, null: false)
      add(:main_image, :string, size: 200, null: false)
      add(:header_image, :string, size: 200, null: true)
      add(:description, :text, null: false)
      add(:status, :integer, null: false)
      add(:priority, :integer, null: false)


      # advanced info
      add(:location, :string, size: 200, null: true)
      add(:unpublish, :utc_datetime, null: true)


      # seo config
      add(:alias_link, :string, size: 200, null: false)
      add(:meta_keywords, :string, size: 200, null: true)
      add(:meta_description, :string, size: 164, null: true)
      add(:custom_title, :string, size: 200, null: true)
      add(:robots, :integer, null: false)


      # ectra config
      add(:post_visibility, :boolean, null: false)

      add(:allow_commenting, :boolean, null: true)
      add(:allow_liking, :boolean, null: true)
      add(:allow_printing, :boolean, null: true)
      add(:allow_reporting, :boolean, null: true)
      add(:allow_social_sharing, :boolean, null: true)
      add(:allow_bookmarking, :boolean, null: true)

      add(:show_hits, :boolean, null: true)
      add(:show_time, :boolean, null: true)
      add(:show_authors, :boolean, null: true)
      add(:show_category, :boolean, null: true)
      add(:show_links, :boolean, null: true)
      add(:show_location, :boolean, null: true)


      add(:category_id, references(:blog_categories, on_delete: :nothing, type: :uuid))

      timestamps()
    end
    create(
      index(:blog_posts, [:alias_link],
        # concurrently: true,
        name: :index_blog_posts_on_alias_link,
        unique: true
      )
    )
  end
end
