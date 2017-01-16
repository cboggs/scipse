defmodule Scipse.HomeController do
  use Scipse.Web, :controller
  plug :auth_user
  
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
