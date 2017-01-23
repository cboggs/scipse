defmodule Scipse.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Scipse.Router.Helpers, as: RouterHelpers
  alias Scipse.User
  require Logger

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user    = user_id && repo.get(Scipse.User, user_id)
    # if no user_id or no such user, assigns nil
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    case conn.assigns.current_user do
      nil ->
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
      %User{} ->
        conn
    end
  end

  #TODO: Make usernames case-insensitive
  def login_by_username_and_pass(conn, username, given_pass, opts) do
    import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Scipse.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def auth_user(conn, _opts) do
    case conn.assigns.current_user do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to access that page.")
        |> redirect(to: RouterHelpers.session_path(conn, :new))
        |> halt()
      %User{} ->
        conn
    end
  end

  def user_is_superadmin(conn) do
    conn.assigns.current_user.superadmin
  end

  def superadmin_only(conn, _opts) do
    case user_is_superadmin(conn) do
      true  -> conn
      false ->
        Logger.warn "Referer: #{inspect(get_req_header(conn, "referer"))}"
        referer_path =
          get_req_header(conn, "referer")
          |> get_referer_path

        conn
        |> put_flash(:error, "Sorry, you must be an admin to do that.")
        |> redirect(to: referer_path)
        |> halt()
    end
  end

  defp get_referer_path([]), do: "/"
  defp get_referer_path([url]) do
    path =
    url
    |> String.split("/")
    |> List.last()

    "/" <> path
  end

end
