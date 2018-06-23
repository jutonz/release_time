defmodule ReleaseTimeWeb.HomeController do
  use ReleaseTimeWeb, :controller
  alias ReleaseTime.GitHub

  def index(conn, _params) do
    token = conn |> get_session(:gh_access_token)
    login = conn |> get_session(:gh_user_login)

    #{:ok, user} = token |> GitHub.me
    {:ok, repos} = token |> GitHub.repos

    conn |> render("index.html", name: login, repos: repos)
  end
end
