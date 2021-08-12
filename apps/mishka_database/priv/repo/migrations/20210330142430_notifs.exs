defmodule MishkaDatabase.Repo.Migrations.Notifs do
  use Ecto.Migration

  def change do
    create table(:notifs, primary_key: false) do

      add(:id, :uuid, primary_key: true)

      add(:status, :integer, null: false)
      add(:section, :integer, null: false)
      add(:section_id, :uuid, primary_key: false, null: true)
      add(:short_description, :string, size: 350, null: true)
      add(:expire_time, :utc_datetime, null: true)
      add(:extra, :map, null: true)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))

      timestamps()
    end
  end
end
