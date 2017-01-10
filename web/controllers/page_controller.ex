defmodule Scipse.PageController do
  use Scipse.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
