defmodule MishkaDatabase.Repo.Migrations.Bookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:status, :integer, null: false)
      add(:section, :integer, null: false, null: false)
      add(:section_id, :uuid, primary_key: false, null: false)
      add(:extra, :map, null: true)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      timestamps()
    end
    create(
      index(:bookmarks, [:section, :section_id, :user_id],
        name: :index_bookmarks_on_section_and_section_id_and_user_id,
        unique: true
      )
    )
  end
end
