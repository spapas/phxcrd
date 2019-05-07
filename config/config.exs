# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phxcrd,
  ecto_repos: [Phxcrd.Repo]

# Configures the endpoint
config :phxcrd, PhxcrdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "45DslMwn2lvg4O3WxPNJk1iJxa93sJQ2ARgQa2C/8YfN6ZnMnjg38MaITvRzdAT6",
  render_errors: [view: PhxcrdWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Phxcrd.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Track changes
config :ex_audit,
  version_schema: Phxcrd.Audit.Version,
  tracked_schemas: [
    Phxcrd.Auth.Authority,
    Phxcrd.Auth.User
  ]

# set config for env
config :phxcrd, env: Mix.env()

# set config for default locale
config :phxcrd, PhxcrdWeb.Gettext, default_locale: "en"

config :scrivener_html,
  routes_helper: Phxcrd.Router.Helpers,
  view_style: :bootstrap_v4

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
