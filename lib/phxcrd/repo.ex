defmodule Phxcrd.Repo do
  # use Ecto.Repo,
  use ExAudit.Repo,
    otp_app: :phxcrd,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
