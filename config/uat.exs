use Mix.Config

config :phxcrd, PhxcrdWeb.Endpoint,
  http: [
    port: 4000
  ],
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  watchers: []

config :phxcrd, Phxcrd.Repo,
  database: "phxcrd_uat",
  hostname: "localhost",
  template: "template0",
  pool_size: 10

config :pdf_generator,
  wkhtml_path: "/usr/local/bin/wkhtmltopdf"

import_config "uat.secret.exs"
