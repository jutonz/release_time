# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :release_time,
  ecto_repos: [ReleaseTime.Repo]

# Configures the endpoint
config :release_time, ReleaseTimeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eKMfcIJ6/tKgk7HcIFApcYz9Mk0VOhQjI8jsg9xMan0fX7ktPeD5TOMV6KwCiEYW",
  render_errors: [view: ReleaseTimeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ReleaseTime.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
