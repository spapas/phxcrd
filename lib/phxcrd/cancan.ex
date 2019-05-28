defimpl Canada.Can, for: Phxcrd.Auth.User do
  # def can?(%User{id: user_id}, action, %Post{user_id: user_id})
  #  when action in [:update, :read, :destroy, :touch], do: true

  # def can?(%User{admin: admin}, action, _)
  #  when action in [:update, :read, :destroy, :touch], do: admin
  alias Phxcrd.Auth.{User, Permission, Authority}
  alias Phxcrd.Audit.Version

  # B careful here: I am passing a fake User struct that has the perms set as a string
  # (take from the current session) to avoid the extra query; this is a hack and
  # may need 2b chagned in the future
  def can?(%User{permissions: permissions}, :index, User) do
    permissions |> Enum.member?("superuser")
  end

  def can?(%User{permissions: permissions}, :index, Permission) do
    permissions |> Enum.member?("superuser")
  end

  def can?(%User{permissions: permissions}, :index, Version) do
    permissions |> Enum.member?("superuser")
  end

  def can?(%User{permissions: permissions}, :index, Authority) do
    permissions |> Enum.any?(&(&1 == "superuser" || &1 == "admin"))
  end

  def can?(%User{permissions: permissions, authority_id: authority_id}, :search, Authority) do
      permissions |> Enum.any?(&(&1 == "superuser" || &1 == "admin")) or (authority_id && authority_id > 0)
  end
end
