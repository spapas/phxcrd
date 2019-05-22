defmodule PhxcrdWeb.PermissionController do
  use PhxcrdWeb, :controller

  alias Phxcrd.Auth
  alias Phxcrd.Auth.User
  alias Phxcrd.Auth.Permission
  alias Phxcrd.Plugs
  import Canada, only: [can?: 2]

  plug Plugs.UserSignedIn
  plug :cancan

  defp cancan(conn, _options) do
    if %User{permissions: conn.assigns[:perms]} |> can?(index(Permission)) do
      conn
    else
      conn
      |> put_flash(:error, "Access Denied!")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  def index(conn, _params) do
    permissions = Auth.list_permissions()
    render(conn, "index.html", permissions: permissions)
  end

  def new(conn, _params) do
    changeset = Auth.change_permission(%Permission{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"permission" => permission_params}) do
    case Auth.create_permission(permission_params) do
      {:ok, permission} ->
        conn
        |> put_flash(:info, "Permission created successfully.")
        |> redirect(to: AdminRoutes.permission_path(conn, :show, permission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    permission = Auth.get_permission!(id)
    render(conn, "show.html", permission: permission)
  end

  def edit(conn, %{"id" => id}) do
    permission = Auth.get_permission!(id)
    changeset = Auth.change_permission(permission)
    render(conn, "edit.html", permission: permission, changeset: changeset)
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    permission = Auth.get_permission!(id)

    case Auth.update_permission(permission, permission_params) do
      {:ok, permission} ->
        conn
        |> put_flash(:info, "Permission updated successfully.")
        |> redirect(to: AdminRoutes.permission_path(conn, :show, permission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", permission: permission, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission = Auth.get_permission!(id)
    {:ok, _permission} = Auth.delete_permission(permission)

    conn
    |> put_flash(:info, "Permission deleted successfully.")
    |> redirect(to: AdminRoutes.permission_path(conn, :index))
  end
end
