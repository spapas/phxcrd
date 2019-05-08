use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :phxcrd, PhxcrdWeb.Endpoint,
  http: [
    port: 4000,
    protocol_options: [
      idle_timeout: 3_600_000 # increase idle timeout
    ]
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :phxcrd, PhxcrdWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/phxcrd_web/{live,views}/.*(ex)$",
      ~r"lib/phxcrd_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :phxcrd, Phxcrd.Repo,
  # set username and password through a secret
  database: "phxcrd_dev",
  hostname: "localhost",
  template: "template0",
  pool_size: 10

import_config "dev.secret.exs"
