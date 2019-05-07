defmodule PhxcrdWeb.AuthorityController do
  use PhxcrdWeb, :controller

  alias Phxcrd.Auth
  alias Phxcrd.Auth.{Authority, User, AuthorityKind}
  alias Phxcrd.Plugs
  alias Phxcrdweb.QueryFilter
  alias Phxcrd.Repo
  import Canada, only: [can?: 2]
  import Ecto.Query, only: [from: 2]

  plug Plugs.UserSignedIn
  plug Plugs.ExAuditPlug
  plug :cancan

  defp cancan(conn, _options) do
    if %User{permissions: conn.assigns[:perms]} |> can?(index(Authority)) do
      conn
    else
      conn
      |> put_flash(:error, "Access Denied!")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  def index(conn, params) do
    changeset =
      case params do
        %{"authority" => authority_params} -> Authority.changeset(%Authority{}, authority_params)
        _ -> Authority.changeset(%Authority{}, %{})
      end

    page =
      from(a in Authority,
        join: ak in AuthorityKind,
        on: [id: a.authority_kind_id],
        preload: [authority_kind: ak]
      )
      |> QueryFilter.filter(%Authority{}, Map.fetch!(changeset, :changes), [
        name: :ilike,
        authority_kind_id: :exact
      ])
      # |> Repo.all()
      |> Repo.paginate(params)

    render(conn, "index.html",
      # authorities: authorities,
      page: page,
      authorities: page.entries,
      changeset: changeset,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def new(conn, _params) do
    changeset = Auth.change_authority(%Authority{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"authority" => authority_params}) do
    case Auth.create_authority(authority_params) do
      {:ok, authority} ->
        conn
        |> put_flash(:info, "Επιτυχής αποθήκευση.")
        |> redirect(to: Routes.authority_path(conn, :show, authority))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    authority = Auth.get_authority!(id)
    render(conn, "show.html", authority: authority)
  end

  def edit(conn, %{"id" => id}) do
    authority = Auth.get_authority!(id)
    changeset = Auth.change_authority(authority)
    render(conn, "edit.html", authority: authority, changeset: changeset)
  end

  def update(conn, %{"id" => id, "authority" => authority_params}) do
    authority = Auth.get_authority!(id)

    case Auth.update_authority(authority, authority_params) do
      {:ok, authority} ->
        conn
        |> put_flash(:info, "Επιτυχής αποθήκευση.")
        |> redirect(to: Routes.authority_path(conn, :show, authority))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", authority: authority, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    authority = Auth.get_authority!(id)
    {:ok, _authority} = Auth.delete_authority(authority)

    conn
    |> put_flash(:info, "Authority deleted successfully.")
    |> redirect(to: Routes.authority_path(conn, :index))
  end
end
