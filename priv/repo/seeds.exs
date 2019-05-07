# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Phxcrd.Repo.insert!(%Phxcrd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Query, only: [from: 2]
alias Phxcrd.Auth.{AuthorityKind, Permission, UserPermission, User}
alias Phxcrd.Repo
alias Phxcrd.Auth

authority_kind_data = [
  %Phxcrd.Auth.AuthorityKind{
    name: "ΚΛ"
  },
  %Phxcrd.Auth.AuthorityKind{
    name: "ΛΧ"
  }
]

case Repo.one(from p in AuthorityKind, select: count(p.id)) do
  0 ->
    IO.puts("** Seeding AuthorityKind")

    Enum.each(authority_kind_data, fn data ->
      Phxcrd.Repo.insert!(data)
    end)

  _ ->
    IO.puts("** Will not seed AuthorityKind")
end

permission_data = [
  %Phxcrd.Auth.Permission{
    name: "superuser",
    verbose_name: "Υπερχρήστης"
  },
  %Phxcrd.Auth.Permission{
    name: "admin",
    verbose_name: "Διαχειριστής"
  }
]

case Repo.one(from p in Permission, select: count(p.id)) do
  0 ->
    Enum.each(permission_data, fn data ->
      Phxcrd.Repo.insert!(data)
    end)

    IO.puts("** Seeding Permission")

  _ ->
    IO.puts("** Will not seed Permission")
end

case Repo.one(from p in UserPermission, select: count(p.id)) do
  0 ->
    user = Repo.one(from u in User, where: u.username == "spapas")
    perm = Repo.one(from u in Permission, where: u.name == "superuser")

    if user && perm do
      IO.puts("** Seeding UserPermission")
      Auth.update_user_and_perms(user, %{"permissions" => [perm.id]})
    else
      IO.puts("** Will not seed UserPermission; user or perm not found")
    end

  _ ->
    IO.puts("** Will not seed UserPermission")
end
