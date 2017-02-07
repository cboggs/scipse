defmodule Scipse.Document do
  use Scipse.Web, :model
  alias Scipse.Repo

  schema "documents" do
    field :name, :string
    field :file, :string
    belongs_to :user, Scipse.User
    #many_to_many :authors, Scipse.Author, join_through: Scipse.DocumentAuthor
    #many_to_many :categories, Scipse.Category, join_through: Scipse.DocumentCategory
    #many_to_many :annotations, Scipse.Annotation, join_through: Scipse.DocumentAnnotation
    #has_many     :comments, Scipse.Comment
  end

  def changeset(document, user, params \\ :invalid) do
    document
    |> Repo.preload(:user)
    |> cast(params, ~w(name file))
    |> validate_required(:name)
    |> validate_required(:file)
    |> unique_constraint(:name)
    |> put_assoc(:user, user)
  end

  def delete_changeset(document, params \\ :invalid) do
    document
    |> cast(params, [:name])
  end
end
