defmodule Scipse.Document do
  use Scipse.Web, :model
  alias Scipse.Repo
  require Logger

  schema "documents" do
    field :name, :string
    field :file_path, :string
    field :file_name, :string
    field :page_count, :integer
    belongs_to :user, Scipse.User
    #many_to_many :authors, Scipse.Author, join_through: Scipse.DocumentAuthor
    #many_to_many :categories, Scipse.Category, join_through: Scipse.DocumentCategory
    #many_to_many :annotations, Scipse.Annotation, join_through: Scipse.DocumentAnnotation
    #has_many     :comments, Scipse.Comment
  end

  def changeset(document, user, params \\ :invalid) do
    Logger.warn("Changeset func recieved params: #{inspect(params)}")
    document
    |> Repo.preload(:user)
    |> cast(params, ~w(name file_path file_name page_count))
    |> validate_required(:name)
    |> validate_required(:file_path)
    |> validate_required(:file_name)
    |> validate_required(:page_count)
    |> unique_constraint(:name)
    |> put_assoc(:user, user)
  end

  def delete_changeset(document, params \\ :invalid) do
    document
    |> cast(params, [:name])
  end
end
