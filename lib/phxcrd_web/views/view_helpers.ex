defmodule PhxcrdWeb.ViewHelpers do
  use Timex

  def get_query_params(params, allowed_keys) do
    params |> Map.take(allowed_keys) |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  def to_local_time(dt) do
    local_tz = Application.get_env(:phxcrd, :local_timezone)
    tz = Timezone.get(local_tz, Timex.now())
    Timezone.convert(dt, tz)
  end

  def to_local_time_str(dt) do
    case dt do
      nil -> "-"
      _ -> dt |> to_local_time |> Timex.format!("{0D}/{0M}/{YYYY} {h24}:{0m}")
    end
  end

  def action_name(conn) do
    Phoenix.Controller.action_name(conn)
  end
end
