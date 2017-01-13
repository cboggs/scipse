defmodule Scipse.Document do
  use Scipse.Web, :model

  schema "documents" do
    field :name, :string
    belongs_to :user, Scipse.User
    #many_to_many :authors, Scipse.Author, join_through: Scipse.DocumentAuthor
    #many_to_many :categories, Scipse.Category, join_through: Scipse.DocumentCategory
    #many_to_many :annotations, Scipse.Annotation, join_through: Scipse.DocumentAnnotation
    #has_many     :comments, Scipse.Comment
  end

end
