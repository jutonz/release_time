defmodule ReleaseTimeWeb.RepoController do
  use ReleaseTimeWeb, :controller
  alias ReleaseTime.{GitHub, Release}

  def show(conn, %{"owner" => owner, "repo" => repo}) do
    login = conn |> get_session(:gh_user_login)
    access_token = conn |> get_session(:gh_access_token)

    {:ok, repo} = access_token |> GitHub.repo(owner, repo)
    {:ok, releases} = repo["id"] |> Release.by_repo_id()

    conn |> render("show.html", name: login, repo: repo, releases: releases)
  end
end
