import Ecto.Query, only: [from: 2]
alias Phxcrd.Auth.{AuthorityKind, Authority}
alias Phxcrd.Repo
alias Phxcrd.Auth

# 1. Put all authority kinds to a Map using their names as key and id as value
authority_kinds =
  from(ak in AuthorityKind, select: %{ak.name => ak.id})
  |> Repo.all()
  |> Enum.reduce(%{}, fn item, acc -> Map.merge(acc, item) end)

case Repo.one(from p in Authority, select: count(p.id)) do
  0 ->
    IO.puts("** Seeding Authority")

    # read CSV file and put it to array
    "authorities.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode(headers: [:authority_kind, :name])
    # Then for each line assign the :authority_kind_id based on :authority_kind
    |> Enum.map(fn {:ok, data} ->
      data |> Map.merge(%{authority_kind_id: authority_kinds[data[:authority_kind]]})
    end)
    # And add each line
    |> Enum.each(fn data -> Auth.create_authority(data) end)

  _ ->
    IO.puts("** Will not seed Authority")
end
