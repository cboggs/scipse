defmodule Scipse.Repo.Migrations.DocumentChangeFileToFilePathAddFileName do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :file_name, :string, null: false
    end

    rename table(:documents), :file, to: :file_path
  end
end
