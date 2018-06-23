defmodule ReleaseTimeWeb.ReleaseController do
  use ReleaseTimeWeb, :controller
  alias ReleaseTime.{GitHub, Release, Repo}

  def index(conn, %{"owner" => owner, "repo" => repo}) do
    conn |> redirect(to: repo_path(conn, :show, owner, repo))
  end

  def new(conn, %{"owner" => owner, "repo" => repo}) do
    login = conn |> get_session(:gh_user_login)
    access_token = conn |> get_session(:gh_access_token)

    {:ok, repo} = access_token |> GitHub.repo(owner, repo)

    changeset = %Release{} |> Release.changeset

    conn |> render("new.html", name: login, repo: repo, changeset: changeset)
  end

  def create(conn, %{"release" => release_params, "owner" => owner, "repo" => repo_name}) do
    access_token = conn |> get_session(:gh_access_token)
    {:ok, repo} = access_token |> GitHub.repo(owner, repo_name)

    release_params = release_params |> Map.put("repo_id", repo["id"])
    cset = %Release{} |> Release.changeset(release_params)
    {:ok, release} = cset |> Repo.insert

    path = conn |> release_path(:show, owner, repo_name, release.name)
    conn |> redirect(to: path)
  end

  def show(conn, %{"owner" => owner, "repo" => repo, "release_name" => release_name}) do
    login = conn |> get_session(:gh_user_login)
    access_token = conn |> get_session(:gh_access_token)

    {:ok, repo} = access_token |> GitHub.repo(owner, repo)
    {:ok, release} = release_name |> Release.get_by_name

    conn |> render("show.html", name: login, repo: repo, release: release)
  end

  def delete(conn, %{"owner" => owner, "repo" => repo, "release_name" => release_name}) do
    {:ok, _release} =
      release_name
      |> Release.get_by_name
      |> Release.changeset
      |> Repo.delete

    conn
    |> put_flash(:info, "Deleted release")
    |> redirect(to: repo_path(conn, :show, owner, repo))
  end
end
