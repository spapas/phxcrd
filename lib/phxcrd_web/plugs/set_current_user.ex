defmodule Phxcrd.Plugs.SetCurrentUser do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)
    username = get_session(conn, :username)
    perms = get_session(conn, :permissions)
    authority_id = get_session(conn, :authority_id)
    authority_name = get_session(conn, :authority_name)

    cond do
      user_id && username ->
        conn
        |> assign(:username, username)
        |> assign(:perms, perms)
        |> assign(:user_id, user_id)
        |> assign(:authority_name, authority_name)
        |> assign(:authority_id, authority_id)
        |> assign(:user_signed_in?, true)

      true ->
        conn
        |> assign(:username, nil)
        |> assign(:user_id, nil)
        |> assign(:perms, [])
        |> assign(:authority_name, nil)
        |> assign(:authority_id, nil)
        |> assign(:user_signed_in?, false)
    end
  end
end
