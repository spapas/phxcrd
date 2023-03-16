defmodule PhxcrdWeb.ViewHelpers do
  use Timex
  import PhxcrdWeb.Gettext
  alias Phoenix.HTML.Form
  import Phoenix.HTML
  use Phoenix.HTML

  # Import basic rendering functionality (render, render_layout, etc)
  import Phoenix.View
  use Phoenix.Component
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
    ~H"""
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
      <div class="container-fluid">
        <a class="navbar-brand" href="/">P·H·X·C·R·D</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbar">
          <div class='d-flex justify-content-between container-fluid'>
            <ul class="navbar-nav mr-auto mb-2 mb-md-0 ">
              <li class="nav-item">
                <a class="nav-link" aria-current="page" href="/"><%= gettext("Home") %></a>
              </li>
              <%= if @user_signed_in? and @perms |> Enum.any?(&(&1 == "superuser" || &1 == "admin")) do %>
                <li class="nav-item dropdown">
                  <a class="nav-link dropdown-toggle" href="#" id="dropdown01" data-bs-toggle="dropdown" aria-expanded="false"><%= gettext("Management") %></a>
                  <ul class="dropdown-menu" aria-labelledby="dropdown01">
                    <%= if @perms |> Enum.member?("superuser") do %>
                      <li>
                        <%= link gettext("Users"), to: AdminRoutes.user_path(@conn, :index), class: "dropdown-item"%>
                      </li>
                      <li>
                        <%= link gettext("Permissions"), to: AdminRoutes.permission_path(@conn, :index), class: "dropdown-item"%>
                      </li>
                      <li>
                        <%= link gettext("Versions"), to: AdminRoutes.version_path(@conn, :index), class: "dropdown-item" %>
                      </li>
                    <% end %>
                    <%= if @perms |> Enum.any?(&(&1 == "superuser" || &1 == "admin")) do %>
                      <li>
                        <%= link gettext("Authorities"), to: AdminRoutes.authority_path(@conn, :index), class: "dropdown-item" %>
                      </li>
                      <li>
                        <%= link gettext("Live Authorities"), to: AdminRoutes.authority_index_path(@conn, :index), class: "dropdown-item" %>
                      </li>
                    <% end %>
                  </ul>
                </li>
              <% end %>
            </ul>

            <ul class="navbar-nav">
              <li class="nav-item">
                <%= if @user_signed_in? do %>
                  <%= form_for @conn, Routes.session_path(@conn, :delete), [ method: :delete, as: :user, id: "logout-form"], fn _ -> %>
                    <%= submit( (@username <> " | " <> gettext("Log out")), class: "btn btn-outline-info btn-sm") %>
                  <% end %>
                <% else %>
                  <%= link gettext("Log in"), to: Routes.session_path(@conn, :new), class: "btn btn-outline-info btn-sm" %>
                <% end %>
              </li>
            </ul>
          </div> <!-- d-flex -->
        </div> <!-- navbar -->
      </div> <!-- container fluid -->
    </nav>

    """
  end

  def get_breadcrumbs(assigns) do
    ~H"""
    """
  end


  def get_sidebar(assigns) do
    ~H"""
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
          <% end %>
            </section>
        </nav>
      </div>
    </div>
    """
  end

  attr :title, :string

  def titleh(assigns) do
    ~H"<h2 class=''><%= @title %></h2>"
  end
  def title(title) do
    ~E"<h2 class=''><%= title %></h2>"
  end

  attr :form, :any, doc: "The datastructure ffor the Phoenix.HTML form"
  attr :field, :atom, doc: "The form field"
  attr :label, :string

  slot :input, required: true

  def form_field(assigns) do
    ~H"""
    <div class="col-12">
      <%= label @form, @field, @label, class: "form-label" %>
      <%= render_slot(@inner_block) %>
      <%= error_tag @form, @field %>
    </div>
    """
  end

  attr :form, :any, doc: "The datastructure for the Phoenix.HTML form"
  attr :field, :atom, doc: "The form field"
  attr :label, :string

  # <.form_text_field form={@f} field={:username} label="Username">
  def form_text_field(assigns) do
    ~H"""
    <.form_field form={@form} field={@field} label={@label}>
      <%= text_input(@form, @field, class: ("form-control " <> (if has_error(@form, @field), do: "is-invalid", else: ""))) %>
    </.form_field>
    """
  end

  attr :form, :any, doc: "The datastructure for the Phoenix.HTML form"
  attr :field, :atom, doc: "The form field"
  attr :label, :string
  def form_pass_field(assigns) do
    ~H"""
    <.form_field form={@form} field={@field} label={@label}>
      <%= password_input(@form, @field, class: ("form-control " <> (if has_error(@form, @field), do: "is-invalid", else: ""))) %>
    </.form_field>
    """
  end

  attr :form, :any, doc: "The datastructure for the Phoenix.HTML form"
  attr :field, :atom, doc: "The form field"
  attr :label, :string
  def form_check_field(assigns) do
    ~H"""
    <.form_field form={@form} field={@field} label={@label}>
      <%= checkbox(@form, @field, class: ("form-control " <> (if has_error(@form, @field), do: "is-invalid", else: ""))) %>
    </.form_field>
    """
  end

  attr :form, :any, doc: "The datastructure for the Phoenix.HTML form"
  attr :field, :atom, doc: "The form field"
  attr :label, :string
  attr :value, :string
  def form_select_field(assigns) do
    ~H"""
    <.form_field form={@form} field={@field} label={@label}>
      <%= select(@form, @field, @value, style: "width: 100%", class: ("form-control " <> (if has_error(@form, @field), do: "is-invalid", else: ""))) %>
    </.form_field>
    """
  end


  attr :form, :any, doc: "The datastructure for the Phoenix.HTML form"
  attr :field, :atom, doc: "The form field"
  attr :label, :string
  attr :values, :string
  attr :selected, :string
  def form_multi_select_field(assigns) do
    ~H"""
    <.form_field form={@form} field={@field} label={@label}>
      <%= multiple_select(@form, @field, @values, selected: @selected, style: "width: 100%", class: ("form-control " <> (if has_error(@form, @field), do: "is-invalid", else: ""))) %>
    </.form_field>
    """
  end


  ##########
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
