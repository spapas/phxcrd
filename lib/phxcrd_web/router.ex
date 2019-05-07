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
  end

  scope "/", PhxcrdWeb do
    pipe_through :browser

    scope "/admin" do
      resources "/authorities", AuthorityController, except: [:delete]
      resources "/users", UserController, only: [:index, :show, :edit, :update]
      resources "/permissions", PermissionController
      resources "/versions", VersionController, only: [:index, :show]
    end

    resources "/sessions", SessionController,
      only: [:new, :create, :delete],
      singleton: true

    get "/", PageController, :index
    get "/test-sentry", PageController, :test_sentry
    get "/test-mail", PageController, :test_mail
    get "/test-pdf", PageController, :test_pdf
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxcrdWeb do
  #   pipe_through :api
  # end
end
