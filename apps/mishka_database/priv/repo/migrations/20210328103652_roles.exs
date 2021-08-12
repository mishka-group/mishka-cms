defmodule MishkaDatabase.Repo.Migrations.Roles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add(:id, :uuid, primary_key: true)


      add(:name, :string, null: false)
      add(:display_name, :string, null: false)

      timestamps()
    end
    create(
      index(:roles, [:display_name],
        name: :index_roles_on_display_name,
        unique: true
      )
    )
  end
end
