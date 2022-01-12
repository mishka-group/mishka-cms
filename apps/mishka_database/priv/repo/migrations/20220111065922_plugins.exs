defmodule MishkaDatabase.Repo.Migrations.Plugins do
  use Ecto.Migration

  def change do
    create table(:plugins, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:name, :string, size: 200, null: false)
      add(:event, :string, size: 200, null: false)
      add(:priority, :integer, null: false)
      add(:status, :integer, null: false)
      add(:depend_type, :integer, null: false)
      add(:depends, {:array, :string}, null: true)
      timestamps()
    end
    create(
      index(:plugins, [:name],
        name: :index_plugins_on_name,
        unique: true
      )
    )
  end
end
