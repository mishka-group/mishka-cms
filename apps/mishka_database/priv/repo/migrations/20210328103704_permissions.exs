defmodule MishkaDatabase.Repo.Migrations.Permissions do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add(:id, :uuid, primary_key: true)


      add(:value, :string, null: false)
      add(:role_id, references(:roles, on_delete: :delete_all, type: :uuid), null: false)
      timestamps()
    end
    create(
      index(:permissions, [:value, :role_id],
        name: :index_permissions_on_value_and_role_id,
        unique: true
      )
    )
  end
end
