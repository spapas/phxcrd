defmodule PhxcrdWeb.AdminRouter do
  use PhxcrdWeb, :router

  scope "/admin", PhxcrdWeb do
    resources "/authorities", AuthorityController, except: [:delete]
    resources "/permissions", PermissionController
    resources "/versions", VersionController, only: [:index, :show]
    resources "/users", UserController, except: [:delete]
    get "/users/:id/change-password", UserController, :change_password_get
    put "/users/:id/change-password", UserController, :change_password_post

    live "/authorities_live", AuthorityLive.Index, :index
    live "/authorities_live/new", AuthorityLive.Index, :new
    live "/authorities_live/:id/edit", AuthorityLive.Index, :edit
    live "/authorities_live/:id", AuthorityLive.Show, :show
    live "/authorities_live/:id/show/edit", AuthorityLive.Show, :edit

    get "/users/:id/photo", UserController, :get_photo
  end
end
