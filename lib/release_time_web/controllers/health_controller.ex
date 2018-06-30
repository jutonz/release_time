defmodule ReleaseTimeWeb.HealthController do
  use ReleaseTimeWeb, :controller

  def healthz(conn, _params) do
    conn |> send_resp(200, "")
  end
end
