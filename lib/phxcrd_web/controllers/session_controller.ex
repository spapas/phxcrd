defmodule PhxcrdWeb.SessionController do
  use PhxcrdWeb, :controller
  alias Phxcrd.Auth
  alias Phxcrd.Repo
  require Logger
  import Ecto.Query, only: [from: 2]

  def new(conn, _) do
    render(conn, "new.html")
  end

  defp get_user_changeset(user_entry) do
    %{
      username: user_entry[:uid],
      name: user_entry[:cn],
      email: user_entry[:mail],
      first_name: user_entry[:givenName],
      last_name: user_entry[:sn],
      kind: user_entry[:departmentNumber],
      extra: user_entry[:initials],
      dsn: user_entry[:object_name],
      am: user_entry[:employeeNumber],
      am_phxcrd: user_entry[:postOfficeBox],
      obj_cls: user_entry[:objectClass],
      last_login: DateTime.utc_now()
    }
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Phxcrd.Ldap.authenticate(username, password) do
      {:ok, user_entry} ->
        user =
          case Repo.one(
                 from u in Auth.User,
                   where: u.username == ^username,
                   left_join: permissions in assoc(u, :permissions),
                   left_join: authority in assoc(u, :authority),
                   preload: [:permissions, :authority]
               ) do
            nil ->
              {:ok, created_user} = user_entry |> get_user_changeset |> Auth.create_user()
              created_user

            existing_user ->
              {:ok, updated_user} =
                existing_user |> Auth.update_user(user_entry |> get_user_changeset)

              updated_user
          end

        authority_name =
          if user.authority_id && user.authority, do: user.authority.name, else: nil

        conn
        |> put_flash(:info, gettext("Welcome %{username}!", username: username))
        |> put_session(:user_id, user.id)
        |> put_session(:username, user.username)
        |> put_session(:permissions, user.permissions |> Enum.map(& &1.name))
        |> put_session(:authority_id, user.authority_id)
        |> put_session(:authority_name, authority_name)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.info("Cannot login #{username}: #{reason}")

        conn
        |> put_flash(:error, gettext("Cannot login: ") <> reason)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
