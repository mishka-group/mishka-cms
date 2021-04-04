defmodule MishkaDatabase.Repo.Migrations.Identities do
  use Ecto.Migration

  def change do
    create table(:identities, primary_key: false) do
      add(:id, :uuid, primary_key: true)


      add(:provider_uid, :string, null: true)
      add(:token, :string, null: true)
      add(:identity_provider, :integer, null: false)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid))
      timestamps()
    end
    create(
      index(:identities, [:provider_uid, :identity_provider],
        name: :index_identities_on_provider_uid_and_identity_provider,
        unique: true
      )
    )

    create(
      index(:identities, [:user_id, :identity_provider],
        name: :index_identities_on_user_id_and_identity_provider,
        unique: true
      )
    )
  end
end
