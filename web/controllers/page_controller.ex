defmodule Scipse.PageController do
  use Scipse.Web, :controller
  alias Scipse.User

  def index(conn, _params) do
    case conn.assigns.current_user do
    nil -> render(conn, "index.html")
    %User{id: id, superadmin: superadmin} ->
      case superadmin do
        true -> redirect(conn, to: "/admin")
        false -> redirect(conn, to: user_path(conn, :show, id))
      end
    end
  end
end
