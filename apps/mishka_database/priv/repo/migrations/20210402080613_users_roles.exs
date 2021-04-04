defmodule MishkaDatabase.Repo.Migrations.UsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:role_id, references(:roles, type: :uuid), null: false)
      add(:user_id, references(:users, type: :uuid), null: false)
      timestamps()
    end
    create(
      index(:users_roles, [:role_id, :user_id],
        name: :index_users_roles_on_role_id_and_user_id,
        unique: true
      )
    )
  end
end
