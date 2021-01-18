defmodule MishkaDatabase.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:full_name, :string, size: 60, null: false)
      add(:username, :string, size: 20, null: true, unique: true)
      add(:email, :string, null: false, unique: true)
      add(:password_hash, :string, null: true)
      add(:status, :integer, null: false)
      add(:unconfirmed_email, :string, size: 120, null: true, unique: true)
      timestamps()
    end
    create(
      index(:users, [:email],
        name: :index_on_users_email,
        unique: true
      )
    )
    create(
      index(:users, [:unconfirmed_email],
        name: :index_on_users_verified_email,
        unique: true
      )
    )
    create(
      index(:users, [:username],
        name: :index_on_users_username,
        unique: true
      )
    )
  end
end
