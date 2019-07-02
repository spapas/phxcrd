defmodule PhxcrdWeb.ViewHelpers do
  use Timex
  import PhxcrdWeb.Gettext
  alias Phoenix.HTML.Form
  import Phoenix.HTML

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

  def localized_date_select(form, field, opts \\ []) do
    builder = fn b ->
      ~e"""
      <%= b.(:day, []) %> / <%= b.(:month, []) %> / <%= b.(:year, []) %>
      """
    end

    opts =
      Keyword.put(opts, :month,
        options: [
          {gettext("January"), "1"},
          {gettext("March"), "3"},
          {gettext("February"), "2"},
          {gettext("April"), "4"},
          {gettext("May"), "5"},
          {gettext("June"), "6"},
          {gettext("July"), "7"},
          {gettext("August"), "8"},
          {gettext("September"), "9"},
          {gettext("October"), "10"},
          {gettext("November"), "11"},
          {gettext("December"), "12"}
        ]
      )

    Form.date_select(form, field, [builder: builder] ++ opts)
  end

  def get_select_value(cs, attr) do
    Ecto.Changeset.get_field(cs, attr)
  end

  def get_select_value2(cs, attr) do
    case cs.changes[attr] do
      nil -> Map.get(cs.data, attr)
      z -> z
    end

    # Or define it like
    # cs |> Ecto.Changeset.get_field(attr)
  end
end
