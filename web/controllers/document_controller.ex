defmodule Scipse.DocumentController do
  use Scipse.Web, :controller
  alias Scipse.Document
  alias Scipse.User
  alias Ecto.Changeset
  require Logger

  plug :superadmin_only when action in [:delete]

  def index(conn, _params) do
    documents = Repo.all(Document)
    render(conn, "index.html", documents: documents)
  end

  def show(conn, %{"id" => document_id}) do
    document = Repo.get(Document, document_id)
    render(conn, "show.html", document: document)
  end

  def new(conn, _params) do
    user = conn.assigns.current_user
    changeset =
      %Document{}
      |> Document.changeset(user)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"document" => document_params}) do
    file_path = document_params["file"].path
    Logger.warn "file: #{inspect(file_path)}"
    case File.exists?(file_path) do
      true  ->
        file_name = Path.basename(file_path, "")
        File.cp!(file_path, "/home/strofcon/temp/scipse/" <> file_name)
      false -> nil
    end

    user = conn.assigns.current_user
    changeset = Document.changeset(%Document{}, user, document_params)
    case Repo.insert(changeset) do
      {:ok, document} ->
        conn
        |> redirect(to: document_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => document_id}) do
    document = Repo.get(Document, document_id)
    changeset = Changeset.change(document)
    case Repo.delete(changeset) do
      {:ok, _document} ->
        Logger.info "User deleted"
        conn
        |> redirect(to: "/documents")
        |> halt()
      {:error, changeset} ->
        Logger.error "Failed to delete document #{inspect(changeset)}"
        conn
        |> put_flash(:error, "Unable to delete document: #{inspect(document.name)}")
        |> redirect(to: document_path(conn, :index))
        |> halt()
    end 
  end 
end
