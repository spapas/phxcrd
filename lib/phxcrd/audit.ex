defmodule Phxcrd.Audit do
  @moduledoc """
  The Audit context.
  """

  import Ecto.Query, warn: false
  alias Phxcrd.Repo
  alias Phxcrd.Audit.Version
  alias Phxcrd.Auth.User

  def list_versions do
    from v in Version,
      left_join: u in User,
      on: [id: v.actor_id],
      preload: [actor: u],
      order_by: [desc: v.recorded_at]
  end

  def get_version!(id), do: Repo.get!(Version, id) |> Repo.preload([:actor])
end
