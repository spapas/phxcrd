defmodule PhxcrdWeb.AuthorityController do
  use PhxcrdWeb, :controller

  alias Phxcrd.Auth
  alias Phxcrd.Auth.{Authority, User, AuthorityKind}
  alias Phxcrd.Plugs
  alias PhxcrdWeb.QueryFilterEx
  alias Phxcrd.Repo
  import Canada, only: [can?: 2]
  import Ecto.Query, only: [from: 2, order_by: 3]

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

  @authority_filters [
    %{
      name: :authority_name,
      type: :string,
      binding: :authority,
      field_name: :name,
      method: :ilike
    },
    %{
      name: :authority_kind_id,
      type: :integer,
      binding: :authority_kind,
      field_name: :id,
      method: :eq
    }
  ]

  @authority_sort_fields [
    "authority__id",
    "authority_kind__name",
    "authority__name"
  ]

  def index(conn, params) do
    changeset = QueryFilterEx.get_changeset_from_params(params, @authority_filters)

    page =
      from(a in Authority,
        as: :authority,
        join: ak in AuthorityKind,
        as: :authority_kind,
        on: [id: a.authority_kind_id],
        preload: [authority_kind: ak]
      )
      |> QueryFilterEx.filter(changeset, @authority_filters)
      |> QueryFilterEx.sort_by_params(params, @authority_sort_fields)
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
        |> put_flash(:info, gettext("Saved!"))
        |> redirect(to: AdminRoutes.authority_path(conn, :show, authority))

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
        |> put_flash(:info, gettext("Saved!."))
        |> redirect(to: AdminRoutes.authority_path(conn, :show, authority))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", authority: authority, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    authority = Auth.get_authority!(id)
    {:ok, _authority} = Auth.delete_authority(authority)

    conn
    |> put_flash(:info, "Authority deleted successfully.")
    |> redirect(to: AdminRoutes.authority_path(conn, :index))
  end
end
