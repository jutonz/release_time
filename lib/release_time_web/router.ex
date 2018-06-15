defmodule ReleaseTimeWeb.Router do
  use ReleaseTimeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ReleaseTimeWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
    get "/github-callback", LoginController, :exchange

    #get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ReleaseTimeWeb do
  #   pipe_through :api
  # end
end
