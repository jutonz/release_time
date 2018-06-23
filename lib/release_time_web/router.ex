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

    get "/login", LoginController, :index
    get "/github-callback", LoginController, :exchange

    pipe_through :authenticated

    get "/", HomeController, :index
    get "/logout", LoginController, :logout
    get "/repos/:owner/:repo", RepoController, :show
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
