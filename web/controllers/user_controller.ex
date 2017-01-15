defmodule Scipse.UserController do
  use Scipse.Web, :controller

  alias Scipse.User
  alias Ecto.Changeset
  require Logger

  plug :auth_user when action in [:index, :show, :delete]

  # TODO: Stop mixing "normal" and "superadmin" user ops in one controller
  plug :superadmin_only when action in [:index, :show, :delete]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => user_id}) do
    user = Repo.get(User, user_id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    changeset =
      %User{}
      |> User.changeset
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params =
      case Repo.all(User) do
        [] -> Map.put_new(user_params, "superadmin", true)
        _else -> Map.put_new(user_params, "superadmin", false)
      end

    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Scipse.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

def delete(conn, %{"id" => user_id}) do
    user = Repo.get(User, user_id)
    changeset = Changeset.change(user)
    case Repo.delete(changeset) do
      {:ok, _user} ->
        Logger.info "User deleted"
        conn
        |> redirect(to: "/users")
        |> halt()
      {:error, changeset} ->
        Logger.error "Failed to delete user #{inspect(changeset)}"
        conn
        |> put_flash(:error, "Unable to delete user: #{inspect(user.name)}")
        |> redirect(to: user_path(conn, :index))
        |> halt()
    end
  end

end
