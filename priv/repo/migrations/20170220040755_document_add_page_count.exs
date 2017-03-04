defmodule Scipse.Repo.Migrations.DocumentAddPageCount do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :page_count, :integer, null: false
    end
  end
end
