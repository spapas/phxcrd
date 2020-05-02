defmodule PhxcrdWeb.Router do
  use PhxcrdWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
    # plug Phoenix.LiveView.Flash
    plug :fetch_live_flash
    plug :put_root_layout, {PhxcrdWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phxcrd.Plugs.SetCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Phxcrd.Plugs.SetCurrentUser
  end

  scope "/", PhxcrdWeb do
    pipe_through :browser

    # forward "/admin", AdminRouter
    match :*, "/admin/*path", AdminRouter, :any

    resources "/sessions", SessionController,
      only: [:new, :create, :delete],
      singleton: true

    get "/", PageController, :index
    get "/test-sentry", PageController, :test_sentry
    get "/test-mail", PageController, :test_mail
    get "/test-pdf", PageController, :test_pdf
    get "/test-xlsx", PageController, :test_xlsx
    get "/test-presence", PageController, :test_presence
    get "/test-live", PageController, :test_live

    live "/authoritiesl", AuthorityLive.Index, :index
    live "/authoritiesl/new", AuthorityLive.Index, :new
    live "/authoritiesl/:id/edit", AuthorityLive.Index, :edit

    live "/authoritiesl/:id", AuthorityLive.Show, :show
    live "/authoritiesl/:id/show/edit", AuthorityLive.Show, :edit
  end

  scope "/api", PhxcrdWeb do
    pipe_through :api

    get "/search_authorities", ApiController, :search_authorities
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard"
    end
  end
end
