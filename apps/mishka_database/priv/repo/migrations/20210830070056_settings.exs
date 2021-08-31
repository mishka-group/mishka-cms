defmodule MishkaDatabase.Repo.Migrations.Settings do
  use Ecto.Migration

  def change do
    create table(:settings, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:section, :integer, null: false)
      add(:configs, :map, null: true)

      timestamps()
    end
    create(
      index(:settings, [:section],
        name: :index_section_on_settings,
        unique: true
      )
    )
  end
end
