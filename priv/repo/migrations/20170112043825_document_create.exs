defmodule Scipse.Repo.Migrations.DocumentCreate do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :name,      :string,  null: false
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
