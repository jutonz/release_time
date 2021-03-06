use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# ReleaseTimeWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :release_time, ReleaseTimeWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "releases.jutonz.com", scheme: :http],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

db_host = System.get_env("PGHOST") || "psql"
db_user = System.get_env("PGUSER")
db_pass = System.get_env("PGPASS")
db_port = System.get_env("PGPORT") || 5432

config :release_time, ReleaseTime.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: db_host,
  username: db_user,
  password: db_pass,
  port: db_port,
  database: "release_time_prod",
  pool_size: 20

secret_key_base = System.get_env("SECRET_KEY_BASE")

config :release_time, ReleaseTimeWeb.Endpoint,
  secret_key_base: secret_key_base


config :release_time, ReleaseTime.GitHub,
  client_id: System.get_env("GH_CLIENT_ID"),
  client_secret: System.get_env("GH_CLIENT_SECRET")
# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :release_time, ReleaseTimeWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :release_time, ReleaseTimeWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :release_time, ReleaseTimeWeb.Endpoint, server: true
#
