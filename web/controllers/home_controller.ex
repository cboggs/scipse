defmodule Scipse.HomeController do
  use Scipse.Web, :controller
  require Logger
  plug :auth_user
  
  def index(conn, _params) do
    Logger.warn "Conn before render: #{inspect(conn)}"
    render(conn, "index.html")
  end
end
