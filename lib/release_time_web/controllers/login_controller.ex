defmodule ReleaseTimeWeb.LoginController do
  use ReleaseTimeWeb, :controller
  alias ReleaseTime.GitHub

  def exchange(conn, %{"code" => code}) do
    case GitHub.exchange(code) do
      {:ok, access_token} ->
        conn
        |> put_flash(:info, "Logged in!")
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, "Failed to login: #{reason}")
        |> redirect(to: "/")
      _ ->
        conn
        |> put_flash(:error, "Failed to login")
        |> redirect(to: "/")
    end
  end
end
