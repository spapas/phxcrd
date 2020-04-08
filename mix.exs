defmodule Phxcrd.MixProject do
  use Mix.Project

  def project do
    [
      app: :phxcrd,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Phxcrd.Application, []},
      extra_applications: [
        :sentry,
        :logger,
        :bamboo,
        :bamboo_smtp,
        :runtime_tools,
        :exldap,
        :pdf_generator,
        # :scrivener,
        :scrivener_ecto,
        :scrivener_html,
        :timex
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.16"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.1.2"},
      {:postgrex, ">=  0.14.3"},
      {:phoenix_html, "~> 2.14.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.16"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},

      # Extra deps
      {:exldap, "~> 0.6"},
      {:canada, "~> 2.0.0"},
      {:ex_audit, "~> 0.6"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},

      # {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:scrivener_html, "~> 1.8"},
      {:sentry, "~> 7.1.0"},
      {:bamboo_smtp, "~> 1.6.0"},
      {:pdf_generator, "== 0.5.2"},
      {:elixlsx, "~> 0.4.1"},
      {:argon2_elixir, "~> 2.0"},
      {:timex, "~> 3.6"},
      {:accessible, "~> 0.2.1"},
      {:csv, "~> 2.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
