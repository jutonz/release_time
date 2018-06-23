defmodule ReleaseTime.GitHub do
  @client_id "0114b02c37a0aae68b02"
  @client_secret "edef8d2cd603b07d4ccebc8210f32ba25795574b"
  @oauth_scope "user,repo"

  def client_id, do: @client_id
  def client_secret, do: @client_secret
  def oauth_scope, do: @oauth_scope

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
    with response <- access_token |> github_connection(:get, url),
         {:ok, body} <- extract_body(response),
      do: {:ok, body}
  end

  def repo(access_token, owner_id, repo_id) do
    url = "https://api.github.com/repos/#{owner_id}/#{repo_id}"
    with response <- access_token |> github_connection(:get, url),
         {:ok, body} <- extract_body(response),
      do: {:ok, body}
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
