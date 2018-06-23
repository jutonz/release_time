defmodule ReleaseTimeWeb.LoginController do
  use ReleaseTimeWeb, :controller
  alias ReleaseTime.GitHub

  def index(conn, _params) do
    case conn |> get_session(:gh_access_token) do
      token when is_bitstring(token) ->
        conn |> redirect(to: "/")
      _ -> 
        conn
        |> render("index.html", client_id: GitHub.client_id(), scope: GitHub.oauth_scope())
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/login")
  end

  def exchange(conn, %{"code" => code}) do
    case GitHub.exchange(code) do
      {:ok, access_token} ->
        {:ok, user} = access_token |> GitHub.me
        conn
        |> put_flash(:info, "Logged in!")
        |> put_session(:gh_user_id, user["id"])
        |> put_session(:gh_user_login, user["login"])
        |> put_session(:gh_access_token, access_token)
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
