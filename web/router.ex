defmodule Scipse.Router do
  use Scipse.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Scipse.Auth, repo: Scipse.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Scipse do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController,         only: [:index, :show, :new, :create, :delete]
    resources "/documents", DocumentController, only: [:index, :show, :new, :create, :delete]
    resources "/sessions", SessionController,   only: [:create, :new, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Scipse do
  #   pipe_through :api
  # end
end
