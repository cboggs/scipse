defmodule Scipse.User do
  use Scipse.Web, :model
  require Logger

  schema "users" do
    field :name, :string
    field :username, :string
    field :email_address, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :joined, :date
    field :last_active, :utc_datetime
    field :superadmin, :boolean
    #has_many :submissions, Scipse.Submission
    #has_many :annotations, Scipse.Annotation
    #has_many :edits, Scipse.Edit
    #has_many :studies, Scipse.Study
    #has_one :author, Scipse.Author
    timestamps()
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username email_address joined), [])
    |> validate_length(:username, min: 1, max: 20)
    |> validate_format(:email_address, ~r/@/)
    |> unique_constraint(:username)
    |> unique_constraint(:email_address)
  end

  def registration_changeset(model, params) do
    params = Map.put_new(params, "joined", Date.utc_today)
    Logger.warn("new user params: #{inspect(params)}")
    model
    |> changeset(params)
    |> cast(params, [:password, :superadmin], [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

end
