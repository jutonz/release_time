defmodule ReleaseTimeWeb.Router do
  use ReleaseTimeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug :require_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ReleaseTimeWeb do
    pipe_through :browser

    get "/healthz", HealthController, :healthz
    get "/login", LoginController, :index
    get "/github-callback", LoginController, :exchange

    pipe_through :authenticated

    get "/", HomeController, :index
    get "/logout", LoginController, :logout
    get "/repos/:owner/:repo", RepoController, :show

    get "/repos/:owner/:repo/releases", ReleaseController, :index
    post "/repos/:owner/:repo/releases", ReleaseController, :create
    get "/repos/:owner/:repo/releases/new", ReleaseController, :new
    get "/repos/:owner/:repo/releases/:release_name", ReleaseController, :show
    delete "/repos/:owner/:repo/releases/:release_name", ReleaseController, :delete
  end

  def require_auth(conn, _options) do
    case token = conn |> get_session(:gh_access_token) do
      token when is_bitstring(token) ->
        conn
      _ ->
        conn
        |> redirect(to: "/login")
        |> halt()
    end
  end
end
