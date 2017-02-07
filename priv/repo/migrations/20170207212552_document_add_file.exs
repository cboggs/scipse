defmodule Scipse.Repo.Migrations.DocumentAddFile do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :file, :string, null: false
    end
  end
end
