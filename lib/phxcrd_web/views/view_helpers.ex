defmodule PhxcrdWeb.ViewHelpers do
  use Timex
  import PhxcrdWeb.Gettext
  alias Phoenix.HTML.Form
  import Phoenix.HTML
  use Phoenix.HTML

  # Import basic rendering functionality (render, render_layout, etc)
  import Phoenix.View

  import PhxcrdWeb.Gettext
  import PhxcrdWeb.ErrorHelpers
  alias PhxcrdWeb.Router.Helpers, as: Routes
  alias PhxcrdWeb.AdminRouter.Helpers, as: AdminRoutes


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

  def get_order_params(params, allowed_keys, order_key) do
    params
    |> Map.take(allowed_keys ++ ["order_by"])
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
    |> Map.update(
      :order_by,
      order_key,
      &case &1 do
        "-" <> ^order_key -> order_key
        ^order_key -> "-" <> order_key
        _ -> "-" <> order_key
      end
    )
  end

  def create_order_url(conn, field_name, ignore \\ ["filter"]) do
    Phoenix.Controller.current_url(conn, get_order_params(conn.params, ignore, field_name))
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

  def get_nav(assigns) do
    ~E"""
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
      <div class="container-fluid">
        <a class="navbar-brand" href="/">P·H·X·C·R·D</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbar">
          <ul class="navbar-nav mr-auto mb-2 mb-md-0">
            <li class="nav-item">
              <a class="nav-link" aria-current="page" href="#">Home</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Link</a>
            </li>
            <li class="nav-item">
              <a class="nav-link disabled" href="#" tabindex="-1" aria-disabled="true">Disabled</a>
            </li>
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" id="dropdown01" data-toggle="dropdown" aria-expanded="false">Dropdown</a>
              <ul class="dropdown-menu" aria-labelledby="dropdown01">
                <li><a class="dropdown-item" href="#">Action</a></li>
                <li><a class="dropdown-item" href="#">Another action</a></li>
                <li><a class="dropdown-item" href="#">Something else here</a></li>
              </ul>
            </li>
          </ul>
          <div class="d-flex">
            <%= if @user_signed_in? do %>
              <%= form_for @conn, Routes.session_path(@conn, :delete), [ method: :delete, as: :user, id: "logout-form"], fn _ -> %>
                <%= submit( (@username <> " | " <> gettext("Log out")), class: "btn btn-outline-info btn-sm") %>
              <% end %>
            <% else %>
              <%= link gettext("Log in"), to: Routes.session_path(@conn, :new), class: "btn btn-outline-info btn-sm" %>
            <% end %>
          </div>
        </div>
      </div>
    </nav>

    """
  end

  def get_breadcrumbs() do
    ~E"""
    """
  end


  def get_sidebar(assigns) do
    ~E"""
    <div class="pf-c-page__sidebar" id='burger-menu' hidden>
      <div class="pf-c-page__sidebar-body">
        <nav class="pf-c-nav" aria-label="Global">
          <section class="pf-c-nav__section" aria-labelledby="grouped-title1">
            <%= if @perms |> Enum.any?(&(&1 == "superuser" || &1 == "admin")) do %>
              <h2 class="pf-c-nav__section-title" id="grouped-title1"><%= gettext "Administration" %></h2>
              <ul class="pf-c-nav__list">
                <li class="pf-c-nav__item">
                  <%= link gettext("Authorities"),
                          to: AdminRoutes.authority_path(@conn, :index),
                          class: "pf-c-nav__link",
                          title: gettext "Authorities"
                    %>
                </li>
                <%= if @perms |> Enum.any?(&( &1 == "superuser")) do %>
                  <li class="pf-c-nav__item">
                    <%= link gettext("Users"),
                                  to: AdminRoutes.user_path(@conn, :index),
                                  class: "pf-c-nav__link",
                                  title: gettext "Users"
                            %>
                  </li>
                  <li class="pf-c-nav__item">
                    <%= link gettext("Permissions"),
                                  to: AdminRoutes.permission_path(@conn, :index),
                                  class: "pf-c-nav__link",
                                  title: gettext "Permissions"
                            %>
                  </li>
                  <li class="pf-c-nav__item">
                    <%= link gettext("Versions"),
                                  to: AdminRoutes.version_path(@conn, :index),
                                  class: "pf-c-nav__link",
                                  title: gettext "Versions"
                            %>
                  </li>
                <% end %>
              </ul>
            </section>
          <% end %>
        </nav>
      </div>
    </div>
    """
  end

  def title(title) do
    ~E"<h2 class=''><%= title %></h2>"
  end

  def get_form_field(fo, fi, label_text, input) do
    ~E"""
    <div class="col-12">
      <%= label fo, fi, label_text, class: "form-label" %>
      <%= input %>
      <%= error_tag fo, fi %>
    </div>
    """
  end

  def get_form_text_field(fo, fi, label_text) do
    get_form_field(fo, fi, label_text, text_input(fo, fi, class: ("form-control " <> (if has_error(fo, fi), do: "is-invalid", else: ""))))
  end

  def get_form_pass_field(fo, fi, label_text) do
    get_form_field(fo, fi, label_text, password_input(fo, fi, class: "form-control"))
  end

  def get_form_check_field(fo, fi, label_text) do
    get_form_field(fo, fi, label_text, checkbox(fo, fi, class: "form-control"))
  end

  def get_form_select_field(fo, fi, label_text, val) do
    get_form_field(fo, fi, label_text, select(fo, fi, val, class: "form-control", style: "width: 100%"))
  end

  def get_form_multi_select_field(fo, fi, label_text, vals, sel ) do
    get_form_field(fo, fi, label_text, multiple_select(fo, fi, vals, selected: sel, class: "form-control",  style: "width: 100%"))
  end



end
