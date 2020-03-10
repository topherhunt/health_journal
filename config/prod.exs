use Mix.Config

config :logger, level: :info

config :health_journal, HealthJournal.Repo,
  url: H.env!("DATABASE_URL"),
  pool_size: 10 # Heroku PG hobby-dev allows max 20 db connections

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :health_journal, HealthJournalWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4000],
  url: [scheme: "https", host: H.env!("HOST_NAME"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

# See https://hexdocs.pm/bamboo_smtp/Bamboo.SMTPAdapter.html#module-example-config
config :health_journal, HealthJournal.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: H.env!("SMTP_SERVER"),
  username: H.env!("SMTP_USERNAME"),
  password: H.env!("SMTP_PASSWORD"),
  port: 587

config :rollbax,
  access_token: H.env!("ROLLBAR_ACCESS_TOKEN"),
  environment: "prod"

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :health_journal, HealthJournalWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         :inet6,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :health_journal, HealthJournalWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.
