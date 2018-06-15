defmodule ReleaseTime.GitHub do
  @client_id "4e7aa0943d61b8cf443c"
  @client_secret "096653ad86f467f114c00f4ac08e28bf0fc56c1b"
  @oauth_scope "user:email"

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

    IO.inspect body

    headers = [{"Accept", "json"}]

    response = HTTPoison.post(
      "https://github.com/login/oauth/access_token",
      body,
      headers
    )

    IO.inspect response

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> 
        {:ok, decoded} = body |> Poison.decode
        IO.inspect decoded
        {:ok, "123"}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "#{status_code}: #{body}"}
      _ ->
        IO.inspect response
        {:error, "nope"}
    end
  end
end
