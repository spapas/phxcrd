defmodule PhxcrdWeb.UserController do
  use PhxcrdWeb, :controller
  alias Phxcrd.Auth
  alias Phxcrd.Auth.{User, Authority, Permission, UserPermission}
  alias Phxcrd.Plugs
  alias Phxcrd.Repo
  alias PhxcrdWeb.QueryFilterEx
  import Canada, only: [can?: 2]
  import Ecto.Query, only: [from: 1, from: 2]

  plug Plugs.UserSignedIn
  plug :cancan

  defp cancan(conn, _options) do
    if %User{permissions: conn.assigns[:perms]} |> can?(index(User)) do
      conn
    else
      conn
      |> put_flash(:error, "Access Denied!")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  @user_filters [
    %{name: :username, type: :string, binding: :user, field_name: :username, method: :ilike},
  ]

  def index(conn, params) do
    changeset = QueryFilterEx.get_changeset_from_params(params, @user_filters)
      
    users =
      from(u in User, as: :user,
        left_join: a in Authority,
        on: a.id == u.authority_id,
        left_join: up in UserPermission,
        on: up.user_id == u.id,
        left_join: p in Permission,
        on: up.permission_id == p.id,
        preload: [authority: a, permissions: p]
      )
      |> QueryFilterEx.filter(changeset, @user_filters)
      |> Repo.all()

    # users = Repo.all(users)
    render(conn, "index.html", users: users, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    changeset = Auth.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Auth.create_db_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: AdminRoutes.user_path(conn, :show, user))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    changeset = Auth.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    user_params = Map.merge(%{"authority_id" => nil}, user_params)

    case Auth.update_user_and_perms(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: AdminRoutes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def change_password_get(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    changeset = Auth.change_user(user)
    render(conn, "change_password.html", user: user, changeset: changeset)
  end

  def change_password_post(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    case Auth.update_user_password(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User password updated successfully.")
        |> redirect(to: AdminRoutes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "change_password.html", user: user, changeset: changeset)
    end
  end

  def get_photo(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    #conn |> html(user.photo_path)
    conn 
    |> put_resp_content_type("image/jpg")
    |> send_file(200, user.photo_path)
  end
end
