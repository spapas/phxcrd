use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phxcrd, PhxcrdWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :phxcrd, Phxcrd.Repo,
  username: "serafeim",
  password: "",
  database: "phxcrd_test",
  hostname: "localhost",
  template: "template0",
  pool: Ecto.Adapters.SQL.Sandbox
