defmodule PhxcrdWeb.ApiController do
  use PhxcrdWeb, :controller
  alias Phxcrdweb.QueryFilter
  alias Phxcrd.Plugs
  alias Phxcrd.Auth
  alias Phxcrd.Auth.{Authority, User, AuthorityKind}
  alias Phxcrd.Repo
  import Canada, only: [can?: 2]
  import Ecto.Query, only: [from: 2, limit: 2]

  plug :user_signed_in
  plug :cancan

  defp user_signed_in(conn, _options) do
    if get_session(conn, :user_id) > 0 do
      conn
    else
      conn
      |> send_resp(403, "Not allowed")
      |> halt
    end
  end

  defp cancan(conn, _options) do
    if %User{permissions: conn.assigns[:perms], authority_id: conn.assigns[:authority_id]}
       |> can?(search(Authority)) do
      conn
    else
      conn
      |> send_resp(403, "Not allowed")
      |> halt
    end
  end

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
