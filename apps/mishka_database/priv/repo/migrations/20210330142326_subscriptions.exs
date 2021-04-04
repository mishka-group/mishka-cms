defmodule MishkaDatabase.Repo.Migrations.Subscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:status, :integer, null: false)
      add(:section, :string, size: 100, null: false)
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))

      add(:page_id, :uuid, primary_key: false)
      add(:type, :integer, null: false)
      add(:expire_time, :utc_datetime, null: true)

      add(:extra, :map, null: true)

      timestamps()
    end
    create(
      index(:subscriptions, [:page_id, :user_id],
        name: :index_subscriptions_on_page_id_and_user_id,
        unique: true
      )
    )
  end
end
