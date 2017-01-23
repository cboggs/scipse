defmodule Scipse.Document do
  use Scipse.Web, :model
  alias Scipse.Repo

  schema "documents" do
    field :name, :string
    belongs_to :user, Scipse.User
    #has_one :file, Scipse.File
    #many_to_many :authors, Scipse.Author, join_through: Scipse.DocumentAuthor
    #many_to_many :categories, Scipse.Category, join_through: Scipse.DocumentCategory
    #many_to_many :annotations, Scipse.Annotation, join_through: Scipse.DocumentAnnotation
    #has_many     :comments, Scipse.Comment
  end

  def changeset(document, user, params \\ :empty) do
    document
    |> Repo.preload(:user)
    |> cast(params, [:name])
    |> unique_constraint(:name)
    |> put_assoc(:user, user)
  end

  def delete_changeset(document, params \\ :empty) do
    document
    |> cast(params, [:name])
  end
end
