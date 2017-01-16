defmodule Scipse.Router do
  use Scipse.Web, :router
  import Scipse.Auth, only: [auth_user: 2, superadmin_only: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    # When conn.current_user exists, does the DB lookup
    plug Scipse.Auth, repo: Scipse.Repo
  end

  pipeline :admin do
    plug :auth_user
    plug :superadmin_only
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Scipse do
    pipe_through :browser

    resources "/",          PageController,     only: [:index]
    resources "/users",     UserController,     only: [:new, :create]
    resources "/home",      HomeController,     only: [:index]
    resources "/documents", DocumentController, only: [:index, :show, :new, :create]
    resources "/sessions",  SessionController,  only: [:create, :new, :delete]
  end

  scope "/admin", Scipse do
    pipe_through [:browser, :admin]
    get "/", AdminController, :index
    resources "/users", UserController,         only: [:index, :show, :delete]
    resources "/documents", DocumentController, only: [:delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Scipse do
  #   pipe_through :api
  # end
end
