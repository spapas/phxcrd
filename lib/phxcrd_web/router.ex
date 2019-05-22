defmodule PhxcrdWeb.Router do
  use PhxcrdWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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

    forward "/admin", AdminRouter
    # scope "/admin" do

    # end

    resources "/sessions", SessionController,
      only: [:new, :create, :delete],
      singleton: true

    get "/", PageController, :index
    get "/test-sentry", PageController, :test_sentry
    get "/test-mail", PageController, :test_mail
    get "/test-pdf", PageController, :test_pdf
    get "/test-xlsx", PageController, :test_xlsx
  end

  scope "/api", PhxcrdWeb do
    pipe_through :api

    get "/search_authorities", ApiController, :search_authorities
  end
end
