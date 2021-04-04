defmodule MishkaDatabase.Repo.Migrations.Bookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:status, :integer, null: false)
      add(:section, :string, size: 100, null: false)
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))

      add(:page_id, :uuid, primary_key: false)

      add(:extra, :map, null: true)

      timestamps()
    end
    create(
      index(:bookmarks, [:page_id, :user_id],
        name: :index_bookmarks_on_page_id_and_user_id,
        unique: true
      )
    )
  end
end
