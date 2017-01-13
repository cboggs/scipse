defmodule Scipse.Repo.Migrations.UserCreate do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name,          :string, null: false
      add :username,      :string, null: false
      add :email_address, :string, null: false
      add :password_hash, :string, null: false
      add :joined,        :date, null: false
      add :last_active,   :utc_datetime
      add :superadmin,    :bool, null: false, default: false
      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
