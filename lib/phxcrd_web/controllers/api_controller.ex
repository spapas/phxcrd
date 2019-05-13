defmodule PhxcrdWeb.ApiController do
  use PhxcrdWeb, :controller
  alias Phxcrdweb.QueryFilter

  alias Phxcrd.Auth
  alias Phxcrd.Auth.{Authority, User, AuthorityKind}
  alias Phxcrd.Repo
  import Canada, only: [can?: 2]
  import Ecto.Query, only: [from: 2, limit: 2]

  def search_authorities(conn, params) do
    q = params["q"]
    authorities =
      from(a in Authority,
        join: ak in AuthorityKind,
        on: [id: a.authority_kind_id],
        preload: [authority_kind: ak],
        where: ilike(a.name, ^"%#{q}%")
      )
      |> limit(20)
      |> Repo.all()

    render(conn, "authorities.json", authorities: authorities)
  end
end
