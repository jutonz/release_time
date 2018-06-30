defmodule ReleaseTime.GitHub do
  alias ReleaseTime.HttpCache

  def client_id do
    Application.get_env(:release_time, ReleaseTime.GitHub)[:client_id]
  end

  def client_secret do
    Application.get_env(:release_time, ReleaseTime.GitHub)[:client_secret]
  end

  def oauth_scope do
    "user,repo"
  end

  @spec exchange(code :: String.t()) :: {:ok, access_token :: String.t()} | {:error, reason :: String.t()}
  def exchange(code) do
    {:ok, body} = Poison.encode(%{
      client_id: client_id(),
      client_secret: client_secret(),
      code: code
    })

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    response = HTTPoison.post(
      "https://github.com/login/oauth/access_token",
      body,
      headers
    )

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> 
        {:ok, decoded} = body |> Poison.decode
        # TODO: Also confirm scope?
        {:ok, decoded["access_token"]}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "#{status_code}: #{body}"}
      _ ->
        {:error, "nope"}
    end
  end

  def me(access_token) do
    url = "https://api.github.com/user"
    with response <- access_token |> github_connection(:get, url),
         {:ok, body} <- extract_body(response),
      do: {:ok, body}
  end

  def repos(access_token) do
    url = "https://api.github.com/user/repos"
    fetch_json(access_token, :get, url)
  end

  def repo(access_token, owner_id, repo_id) do
    url = "https://api.github.com/repos/#{owner_id}/#{repo_id}"
    fetch_json(access_token, :get, url)
  end

  defp extract_body(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> 
        {:ok, decoded} = body |> Poison.decode
        # TODO: Also confirm scope?
        {:ok, decoded}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "#{status_code}: #{body}"}
      _ ->
        {:error, "Something went wrong"}
    end
  end

  def fetch_json(access_token, method, url, opts \\ []) do
    #default_opts = [use_cache: true]
    #options = Keyword.merge(opts, default_opts) |> Enum.into(%{})
    #%{use_cache: use_cache} = options

    #case use_cache do
      #true
    #end

    cache_key = "#{url}:#{access_token}"
    case HttpCache.get(cache_key) do
      {:hit, body} -> {:ok, body}
      _ -> (
        response = access_token |> github_connection(method, url, opts)
        {:ok, body} = extract_body(response)
        HttpCache.set(cache_key, body)
        {:ok, body}
      )
    end
  end

  def github_connection(access_token, method, url, opts \\ []) do
    default_opts = [body: "", headers: []]
    options = Keyword.merge(opts, default_opts) |> Enum.into(%{})
    %{body: body, headers: user_headers} = options

    persistent_headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Accept", "application/vnd.github.v3+json"},
      {"User-Agent", "ReleaseTime [dev]"}
    ]
    headers = user_headers ++ persistent_headers

    case method do
      :get -> HTTPoison |> apply(method, [url, headers])
      _ -> HTTPoison |> apply(method, [url, body, headers])
    end
  end
end
