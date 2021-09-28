defmodule MishkaDatabase.Repo.Migrations.Activities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add(:id, :uuid, primary_key: true)


      add(:type, :integer, null: false)
      add(:action, :integer, null: false)
      add(:section, :integer, null: false, null: false)
      add(:section_id, :uuid, primary_key: false, null: true)
      add(:priority, :integer, null: false)
      add(:status, :integer, null: false)
      add(:extra, :map, null: true)
      add(:user_id, references(:users, type: :uuid), null: true)

      timestamps()
    end
  end
end
