defmodule PhxcrdWeb.QueryFilterEx do
  import Ecto.Query

  defp make_filter_keys(filters) do
    filters |> Enum.map(& &1.name)
  end

  defp make_filter_types(filters) do
    filters |> Enum.map(&{&1.name, &1.type}) |> Map.new()
  end

  defp make_filter_changeset(filters, params) do
    data = %{}
    types = filters |> make_filter_types

    {data, types}
    |> Ecto.Changeset.cast(params, filters |> make_filter_keys)
    |> Map.merge(%{action: :insert})
  end

  def get_changeset_from_params(params, filters, filter_name \\ "filter") do
    case params do
      %{^filter_name => filter_params} ->
        filters |> make_filter_changeset(filter_params)

      _ ->
        filters |> make_filter_changeset(%{})
    end
  end

  def filter(query, changeset, filters) do
    changes = Map.fetch!(changeset, :changes)
    filters |> Enum.reduce(query, creat_where_clauses_reducer(changes))
  end

  defp creat_where_clauses_reducer(changes) do
    fn %{name: name, field_name: field_name, binding: binding, method: method}, acc ->
      case Map.fetch(changes, name) do
        {:ok, value} ->
          acc |> creat_where_clause(field_name, binding, method, value)

        _ ->
          acc
      end
    end
  end

  defp creat_where_clause(acc, field_name, binding, method, value) do
    case method do
      :eq ->
        acc
        |> where(
          [{^binding, t}],
          field(t, ^field_name) == ^value
        )

      :ilike ->
        acc
        |> where(
          [{^binding, t}],
          ilike(field(t, ^field_name), ^"#{value}%")
        )

      :icontains ->
        acc
        |> where(
          [{^binding, t}],
          ilike(field(t, ^field_name), ^"%#{value}%")
        )

      :year ->
        acc
        |> where(
          [{^binding, t}],
          fragment("extract (year from ?) = ?", field(t, ^field_name), ^value)
        )

      :date ->
        acc
        |> where(
          [{^binding, t}],
          fragment(
            "? >= cast(? as date) and ? < (cast(? as date) + '1 day'::interval)",
            field(t, ^field_name),
            ^value,
            field(t, ^field_name),
            ^value
          )
        )

      _ ->
        acc
        |> where(
          [{^binding, t}],
          field(t, ^field_name) == ^value
        )
    end
  end

  defp do_sort_by_params(qs, val, ord, allowed) do
    if val in allowed do
      [binding, name] = val |> String.split("__") |> Enum.map(&String.to_atom/1)
      qs |> order_by([{^binding, t}], [{^ord, field(t, ^name)}])
    else
      qs
    end
  end

  def sort_by_params(qs, %{"order_by" => "-" <> val}, allowed),
    do: do_sort_by_params(qs, val, :asc, allowed)

  def sort_by_params(qs, %{"order_by" => val}, allowed),
    do: do_sort_by_params(qs, val, :desc, allowed)

  def sort_by_params(qs, _, _), do: qs
end
