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

  def get_breadcrumbs() do
    ~E"""
      <section class="pf-c-page__main-breadcrumb">
      <nav class="pf-c-breadcrumb" aria-label="breadcrumb">
        <ol class="pf-c-breadcrumb__list">
          <li class="pf-c-breadcrumb__item">
            <a href="#" class="pf-c-breadcrumb__link">Section home</a>
          </li>

          <li class="pf-c-breadcrumb__item">
            <span class="pf-c-breadcrumb__item-divider">
              <i class="fas fa-angle-right" aria-hidden="true"></i>
            </span>
            <a href="#" class="pf-c-breadcrumb__link pf-m-current" aria-current="page">Section landing</a>
          </li>
        </ol>
      </nav>
    </section>
    """
  end

  def get_header_horizontal_nav() do
    ~E"""
    <div class="pf-c-page__header-nav">
      <nav class="pf-c-nav pf-m-horizontal pf-m-scrollable" aria-label="Global">
        <button class="pf-c-nav__scroll-button" id='scroll-left' aria-label="Scroll left">
          <i class="fas fa-angle-left" aria-hidden="true"></i>
        </button>
        <ul class="pf-c-nav__list">
          <li class="pf-c-nav__item">
            <a href="#" class="pf-c-nav__link">Horizontal nav item 1</a>
          </li>
          <li class="pf-c-nav__item">
            <a href="#" class="pf-c-nav__link pf-m-current" aria-current="page">Horizontal nav item 5</a>
          </li>
        </ul>
        <button class="pf-c-nav__scroll-button" id='scroll-right' aria-label="Scroll right">
          <i class="fas fa-angle-right" aria-hidden="true"></i>
        </button>
      </nav>
    </div>
    """
  end

  def get_header_tools(assigns) do
    ~E"""
    <div class="pf-c-page__header-tools" id='kebab-container'>
      <div class="pf-c-dropdown pf-m-expanded">
        <button id='kebab-button' class="pf-c-dropdown__toggle pf-m-plain" type="button" id="dropdown-kebab-align-right-button" aria-expanded="true" aria-label="Actions">
          <i class="fas fa-ellipsis-v" aria-hidden="true"></i>
        </button>
        <ul class="pf-c-dropdown__menu pf-m-align-right" aria-labelledby="dropdown-kebab-align-right-button" id='kebab-menu' hidden>
          <li>
            <a class="pf-c-dropdown__menu-item" href="/"><%= gettext("Home") %></a>
          </li>
          <li class="pf-c-divider" role="separator"></li>
          <li>
              <%= if @user_signed_in? do %>
              <%= link (@username <> " | " <> gettext "Log out"), to: "#", id: "logout-button", class: "pf-c-dropdown__menu-item" %>
              <%= form_for @conn, Routes.session_path(@conn, :delete), [style: "display: none;", method: :delete, as: :user, id: "logout-form"], fn _ -> %>
                <%= submit @username <> " | " <> gettext "Log out", class: "pf-c-dropdown__menu-item" %>
              <% end %>
              <% else %>
              <%= link gettext("Log in"), to: Routes.session_path(@conn, :new), class: "pf-c-dropdown__menu-item" %>
              <% end %>
          </li>
        </ul>
      </div>
    </div>
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
    ~E"<h1 class='pf-c-title pf-m-3xl'><%= title %></h1>"
  end

  def get_form_field(fo, fi, input) do
    ~E"""
    <div class="pf-c-form__group">
      <div class="pf-c-form__group-label">
        <label class="pf-c-form__label" for="help-text-form-address">
          <%= label(fo, fi, class: "pf-c-form__label-text") %>
          <span class="pf-c-form__label-required" aria-hidden="true">&#42;</span>
        </label>
      </div>
      <div class="pf-c-form__group-control">
        <%= input %>
        <%= error_tag(fo, fi) %>
      </div>
    </div>
    """
  end

  def get_form_text_field(fo, fi) do
    get_form_field(fo, fi, text_input(fo, fi, class: "pf-c-form-control"))
  end

  def get_form_pass_field(fo, fi) do
    get_form_field(fo, fi, password_input(fo, fi, class: "pf-c-form-control"))
  end

  def get_form_check_field(fo, fi) do
    get_form_field(fo, fi, checkbox(fo, fi, class: "pf-c-check__input"))
  end

  def get_form_select_field(fo, fi, val) do
    get_form_field(fo, fi, select(fo, fi, val, class: "pf-c-form-control", style: "width: 100%"))
  end

  def get_form_multi_select_field(fo, fi, vals, sel ) do
    get_form_field(fo, fi, multiple_select(fo, fi, vals, selected: sel, class: "pf-c-form-control",  style: "width: 100%"))
  end



end
