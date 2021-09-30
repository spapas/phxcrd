defmodule Phxcrd.Repo do
  use Ecto.Repo,
    otp_app: :phxcrd,
    adapter: Ecto.Adapters.Postgres

  use ExAudit.Repo
  use Scrivener, page_size: 10
end
