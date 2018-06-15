defmodule ReleaseTimeWeb.PageController do
  use ReleaseTimeWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
