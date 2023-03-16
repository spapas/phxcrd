# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phxcrd,
  ecto_repos: [Phxcrd.Repo]

# Configures the endpoint
config :phxcrd, PhxcrdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "45DslMwn2lvg4O3WxPNJk1iJxa93sJQ2ARgQa2C/8YfN6ZnMnjg38MaITvRzdAT6",
  # render_errors: [view: PhxcrdWeb.ErrorHTML, accepts: ~w(html json)],
  render_errors: [
    formats: [html: LiveBeatsWeb.ErrorHTML, json: LiveBeatsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Phxcrd.PubSub,
  live_view: [signing_salt: "xLfrf2IO"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Track changes with ExAudit
config :ex_audit,
  version_schema: Phxcrd.Audit.Version,
  tracked_schemas: [
    Phxcrd.Auth.Authority,
    Phxcrd.Auth.User
  ]

# Exldap settings
config :exldap, :settings,
  # cfg server and base through a secret
  port: 389,
  ssl: false,
  search_timeout: 5_000

# Sentry settings
config :sentry,
  # dsn should be configured through a secret
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: Mix.env() |> Atom.to_string()
  },
  # :dev is here only for testing, remove it after you confirm it works
  included_environments: [:prod, :uat]

# Bamboo smtp settings
config :phxcrd, Phxcrd.Mailer,
  # configure server, hostname, username and password through a secret
  adapter: Bamboo.SMTPAdapter,
  port: 587,
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1,
  no_mx_lookups: false,
  auth: :always

# set config for env
# for example to use <%= Application.get_env(:phxcrd, :env) %> in your templates
config :phxcrd,
  env: Mix.env(),
  local_timezone: "Europe/Athens",
  media_root: "./media/"

# set config for default locale
config :phxcrd, PhxcrdWeb.Gettext, default_locale: "en"

config :scrivener_html,
  routes_helper: Phxcrd.Router.Helpers,
  view_style: :bootstrap_v4

config :pdf_generator,
  wkhtml_path: "c:/util/wkhtmltopdf.exe"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
