defmodule MishkaDatabase.Repo.Migrations.Subscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:status, :integer, null: false)
      add(:section, :integer, null: false, null: false)
      add(:section_id, :uuid, primary_key: false, null: false)
      add(:expire_time, :utc_datetime, null: true)
      add(:extra, :map, null: true)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      timestamps()
    end
    create(
      index(:subscriptions, [:section, :section_id, :user_id],
        name: :index_subscriptions_on_section_and_section_id_and_user_id,
        unique: true
      )
    )
  end
end
