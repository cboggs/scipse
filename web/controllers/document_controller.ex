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
    Logger.warn("Document param sent to show page: #{inspect(document)}")
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
    {param_file_path, param_file_name} = case document_params["file"] do
      nil -> {"", ""} 
      file -> {file.path, file.filename}
    end

    Logger.warn "file: #{inspect(param_file_path)}"

    store_file_path = case File.exists?(param_file_path) do
      true  ->
        url_path = Application.get_env(:scipse, Scipse.Endpoint)[:pdf_url_path]
        store_file_name = Path.basename(param_file_path)
        dest_path = Path.join(["priv", "static",
                               url_path, store_file_name])
        File.cp!(param_file_path, dest_path)
        Path.join(url_path, store_file_name)
      false -> nil
    end

    changeset_params = %{name: document_params["name"],
                         file_path: store_file_path,
                         file_name: document_params["file"].filename}

    Logger.warn("CHANGESET_PARAMS: #{inspect(changeset_params)}")

    user = conn.assigns.current_user
    changeset = Document.changeset(%Document{}, user, changeset_params)

    case Repo.insert(changeset) do
      {:ok, document} ->
        conn
        |> redirect(to: document_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => document_id}) do
    document = Repo.get(Document, document_id)
    changeset = Changeset.change(document)
    case Repo.delete(changeset) do
      {:ok, _document} ->
        Logger.info "Document deleted"
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
