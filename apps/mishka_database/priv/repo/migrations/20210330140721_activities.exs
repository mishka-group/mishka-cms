defmodule MishkaDatabase.Repo.Migrations.Activities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add(:id, :uuid, primary_key: true)


      add(:type, :string, size: 100, null: false)
      add(:section, :string, size: 100, null: false)
      add(:priority, :integer, null: false)
      add(:status, :integer, null: false)
      add(:extra, :map, null: true)

      timestamps()
    end
  end
end
