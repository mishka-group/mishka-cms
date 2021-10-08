defmodule MishkaDatabase.Repo.Migrations.UserNotifStatuses do
  use Ecto.Migration

  def change do
    create table(:user_notif_statuses, primary_key: false) do

      add(:id, :uuid, primary_key: true)
      add(:type, :integer, null: false)
      add(:user_id, references(:users, on_delete: :nothing, type: :uuid), null: false)
      add(:notif_id, references(:notifs, on_delete: :delete_all, type: :uuid), null: false)

      timestamps()
    end
    create(
      index(:user_notif_statuses, [:user_id, :notif_id],
        name: :index_user_notif_on_user_notif_statuses,
        unique: true
      )
    )
  end
end
