defmodule Scipse.DocumentController do
  use Scipse.Web, :controller
  alias Scipse.Document
  alias Scipse.PDFUtil
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
    incoming_file_path = case document_params["file"] do
      nil -> ""
      file -> file.path
    end

    # Do some work up front to determine if the PDF is still around and
    #  where we should put it
    static_asset_url_path = Application.get_env(:scipse, Scipse.Endpoint)[:pdf_url_path]
    store_file_name = Path.basename(incoming_file_path)
    store_file_path = Path.join(["priv", "static",
                           static_asset_url_path, store_file_name])

    url_file_path = case File.exists?(incoming_file_path) do
      true  ->
        Path.join(static_asset_url_path, store_file_name)
      false ->
        Logger.error "Failed to process document #{inspect(document_params)}"
        conn
        |> put_flash(:error, "Error processing document.")
        |> redirect(to: document_path(conn, :new))
        |> halt()
    end

    user = conn.assigns.current_user
    pdf_page_count = PDFUtil.get_page_count(incoming_file_path)
    changeset_params = %{name: document_params["name"],
                         file_path: url_file_path,
                         file_name: document_params["file"].filename,
                         page_count: pdf_page_count}
    changeset = Document.changeset(%Document{}, user, changeset_params)

    case Repo.insert(changeset) do
      {:ok, _document} ->
        # Stick the PDF in a non-transient location
        File.cp!(incoming_file_path, store_file_path)

        conn
        |> put_flash(:info, "Document successfully submitted!")
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
