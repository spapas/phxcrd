defmodule PhxcrdWeb.ViewHelpers do
  use Timex

  def get_query_params(params) do
    params |> Map.delete("page") |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  def to_local_time(dt) do
    local_tz = Application.get_env(:phxcrd, :local_timezone)
    tz = Timezone.get(local_tz, Timex.now())
    Timezone.convert(dt, tz)
  end

  def to_local_time_str(dt) do
    dt |> to_local_time |> Timex.format!("{0D}/{0M}/{YYYY} {h24}:{0m}")
  end
end
