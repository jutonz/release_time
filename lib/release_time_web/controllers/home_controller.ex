defmodule ReleaseTimeWeb.HomeController do
  use ReleaseTimeWeb, :controller
  alias ReleaseTime.GitHub

  def index(conn, _params) do
    conn
    |> render("index.html", client_id: GitHub.client_id, scope: GitHub.oauth_scope)
  end
end
