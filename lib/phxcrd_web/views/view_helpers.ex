defmodule PhxcrdWeb.ViewHelpers do
    def get_query_params(params) do
        params  |> Map.delete("page") |> Enum.map( fn {k, v} -> {String.to_atom(k), v} end)
    end
end
