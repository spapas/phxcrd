defmodule PhxcrdWeb.SessionController do
  use PhxcrdWeb, :controller
  alias Phxcrd.Auth
  alias Phxcrd.Repo
  require Logger
  import Ecto.Query, only: [from: 2]
  import IEx

  def new(conn, _) do
    render(conn, "new.html")
  end

  defp get_ldap_user_changeset(user_entry) do
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
      password_hash: nil,
      last_login: DateTime.utc_now()
    }
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case ldap_login(username, password) do
      {:ok, user} ->
        auth_successfull(conn, user)

      {:error, reason} ->
        Logger.info("Cannot login #{username} through LDAP: #{reason}. Will try DB login.")

        case db_login(username, password) do
          {:ok, user} ->
            auth_successfull(conn, user)

          {:error, reason} ->
            Logger.info("Cannot login #{username} through DB: #{reason}.")

            conn
            |> put_flash(:error, gettext("Cannot login"))
            |> redirect(to: Routes.session_path(conn, :new))
        end
    end
  end

  def delete(conn, _) do
    conn
    # |> configure_session(drop: true)
    |> clear_session()
    |> put_flash(:info, gettext("You've been logged out"))
    |> redirect(to: "/")
  end

  defp is_disabled?(user) do
    !(user |> Map.fetch!(:is_enabled))
  end

  defp ldap_login(username, password) do
    with {:ok, user_entry} <- Phxcrd.Ldap.authenticate(username, password) do
      user =
        case Repo.one(
               from u in Auth.User,
                 where: u.username == ^username,
                 left_join: permissions in assoc(u, :permissions),
                 left_join: authority in assoc(u, :authority),
                 preload: [:permissions, :authority]
             ) do
          nil ->
            {:ok, created_user} = user_entry |> get_ldap_user_changeset |> Auth.create_user()
            created_user

          existing_user ->
            {:ok, updated_user} =
              existing_user |> Auth.update_user(user_entry |> get_ldap_user_changeset)

            updated_user
        end

      {:ok, user}
    end
  end

  defp db_login(username, password) do
    # case Auth.get_user_by_username(username) do
    #  {:ok, user} -> user |> Argon2.check_pass(password)
    #  {:error, reason} -> {:error, reason}
    # end
    # With is more idiomatic

    with {:ok, user} <- Auth.get_for_db_login(username),
         {:ok, user} <- Argon2.check_pass(user, password) do
      Auth.update_user(user, %{last_login: DateTime.utc_now()})
    end
  end

  defp auth_successfull(conn, user) do
    # authority_name = if user.authority_id && user.authority, do: user.authority.name, else: nil
    # authority_name =
    #  case user do
    #    %{authority: %{name: name}} -> name
    #    _ -> nil
    #  end
    # IEx.pry
    case user |> is_disabled? do
      true ->
        conn
        |> put_flash(:error, gettext("Cannot login (user is disabled)"))
        |> redirect(to: Routes.session_path(conn, :new))

      false ->
        conn
        |> put_flash(:info, gettext("Welcome %{username}!", username: user.username))
        |> put_session(:user_id, user.id)
        |> put_session(:username, user.username)
        |> put_session(:permissions, user.permissions |> Enum.map(& &1.name))
        |> put_session(:authority_id, user.authority_id)
        |> put_session(:authority_name, get_in(user, [:authority, :name]))
        |> configure_session(renew: true)
        |> redirect(to: "/")
    end
  end
end
