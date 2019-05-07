defmodule Phxcrdweb.QueryFilter do
  import IEx
  import Ecto.Query

  def filter(query, model, params, filters) do
    where_clauses = cast(model, params, filters)

    query
    |> where(^where_clauses)
  end

  def cast(model, params, filters) do
    Ecto.Changeset.cast(model, params, filters |> Keyword.keys())
    |> Map.fetch!(:changes)
    |> add_where_clauses(filters)
  end

  defp add_where_clauses(changes, filters) do
    filters
    |> Enum.reduce(true, creat_where_clauses_reducer(changes))
  end

  defp creat_where_clauses_reducer(changes) do
    fn {k, filter_type}, acc ->
      case filter_type do
        :ilike ->
          case Map.fetch(changes, k) do
            {:ok, v} ->
              dynamic([z], ilike(field(z, ^k), ^(v <> "%")) and ^acc)

            _ ->
              acc
          end

        _ ->
          case Map.fetch(changes, k) do
            {:ok, v} ->
              dynamic([z], field(z, ^k) == ^v and ^acc)

            _ ->
              acc
          end
      end
    end
  end
end
