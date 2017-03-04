defmodule Scipse.Repo.Migrations.DocumentAddUniqueIdxName do
  use Ecto.Migration

  def change do
    create unique_index(:documents, [:name])
  end
end
