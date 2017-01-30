defmodule Scipse.AdminController do
  use Scipse.Web, :controller
  alias Scipse.User

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
