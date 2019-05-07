defmodule PhxcrdWeb.VersionController do
  use PhxcrdWeb, :controller
  alias Phxcrd.Audit
  alias Phxcrd.Auth.User
  alias Phxcrd.Audit.Version
  alias Phxcrd.Plugs
  alias Phxcrd.Repo
  alias Phxcrdweb.QueryFilter
  import Canada, only: [can?: 2]

  plug Plugs.UserSignedIn
  plug :cancan

  defp cancan(conn, _options) do
    if %User{permissions: conn.assigns[:perms]} |> can?(index(Version)) do
      conn
    else
      conn
      |> put_flash(:error, "Access Denied!")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  defp get_entity_schema_atom(v) do
    v
    # |> String.replace_prefix("", "Elixir.")
    |> String.to_atom()
    |> ExAudit.Type.Schema.cast()
    |> elem(1)
  end

  def index(conn, params) do
    changeset =
      case params do
        %{"version" => %{"entity_schema" => ""} = version_params} ->
          Version.changeset(%Version{}, version_params)
        %{"version" => version_params} ->
          Version.changeset(%Version{}, version_params)
          |> Ecto.Changeset.put_change(
            :entity_schema,
            version_params |> Map.fetch!("entity_schema") |> get_entity_schema_atom()
          )

        _ ->
          Version.changeset(%Version{}, %{})
      end

    page =
      Audit.list_versions()
      |> QueryFilter.filter(%Version{}, Map.fetch!(changeset, :changes),
        entity_schema: :exact,
        entity_id: :exact
      )
      |> Repo.paginate(params)

    render(conn, "index.html",
      page: page,
      changeset: changeset,
      versions: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def show(conn, %{"id" => id}) do
    version = Audit.get_version!(id)
    render(conn, "show.html", version: version)
  end
end
