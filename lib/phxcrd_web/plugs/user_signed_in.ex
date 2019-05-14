defmodule Phxcrd.Plugs.UserSignedIn do
  import Plug.Conn
  alias PhxcrdWeb.Router.Helpers, as: Routes

  def init(_params) do
  end

  def call(conn, _params) do
    IO.inspect(conn)
    IO.inspect(_params)

    if conn.assigns[:user_signed_in?] do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "Access Denied!")
      |> Phoenix.Controller.redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end
end
