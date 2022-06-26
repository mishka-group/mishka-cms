defmodule MishkaDatabase.Repo.Migrations.UserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:token, :text, null: false)
      add(:type, :integer, null: false)
      add(:expire_time, :utc_datetime, null: false)
      add(:extra, :map, null: false)

      add(:user_id, references(:users, on_delete: :nothing, type: :uuid), null: false)
      timestamps()
    end
    create(
      index(:user_tokens, [:token],
        name: :index_token_on_user_tokens,
        unique: true
      )
    )
  end
end
