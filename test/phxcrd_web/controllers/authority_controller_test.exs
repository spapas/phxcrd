defmodule PhxcrdWeb.AuthorityControllerTest do
  use PhxcrdWeb.ConnCase
  alias Phxcrd.Auth

  @create_attrs %{name: "some name", authority_kind_id: 1}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:authority) do
    {:ok, authority_kind} = Auth.create_authority_kind(%{name: "some name"})

    {:ok, authority} =
      Auth.create_authority(%{@create_attrs | authority_kind_id: authority_kind.id})

    authority
  end

  def fixture(:authority_kind) do
    {:ok, authority_kind} = Auth.create_authority_kind(%{name: "some name2"})
    authority_kind
  end

  def fixture(:user) do
    {:ok, user} =
      Auth.create_db_user(%{
        name: "some name",
        first_name: "some name",
        last_name: "some name",
        username: "username",
        password: "pwd",
        email: "email"
      })

    user
  end

  defp fake_sign_in(conn, user_id \\ 1) do
    conn
    |> Plug.Test.init_test_session(%{})
    |> Plug.Conn.put_session(:permissions, ["admin"])
    |> Plug.Conn.put_session(:user_signed_in?, true)
    |> Plug.Conn.put_session(:user_id, user_id)
    |> Plug.Conn.put_session(:username, "test")
  end

  describe "index" do
    test "lists all authorities", %{conn: conn} do
      conn = get(conn |> fake_sign_in, Routes.authority_path(conn, :index))
      assert html_response(conn, 200) =~ "Authority list"
    end

    test "does not allow anonymous access", %{conn: conn} do
      conn = get(conn, Routes.authority_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
    end

    test "does not allow access without permissions", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:permissions, [])
        |> Plug.Conn.put_session(:user_signed_in?, true)
        |> Plug.Conn.put_session(:user_id, 1)
        |> Plug.Conn.put_session(:username, "test")

      conn = get(conn, Routes.authority_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
    end
  end

  describe "new authority" do
    test "renders form", %{conn: conn} do
      conn = get(conn |> fake_sign_in, Routes.authority_path(conn, :new))
      assert html_response(conn, 200) =~ "New authority"
    end
  end

  describe "create authority" do
    setup [:create_authority_kind, :create_user]

    test "redirects to show when data is valid", %{
      conn: conn,
      authority_kind: authority_kind,
      user: user
    } do
      conn =
        post(conn |> fake_sign_in(user.id), Routes.authority_path(conn, :create),
          authority: %{@create_attrs | authority_kind_id: authority_kind.id}
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.authority_path(conn, :show, id)

      conn = get(conn, Routes.authority_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Authority"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn |> fake_sign_in, Routes.authority_path(conn, :create), authority: @invalid_attrs)

      assert html_response(conn, 200) =~ "New authority"
    end
  end

  describe "edit authority" do
    setup [:create_authority]

    test "renders form for editing chosen authority", %{
      conn: conn,
      authority: authority
    } do
      conn =
        get(
          conn |> fake_sign_in,
          Routes.authority_path(conn, :edit, authority)
        )

      assert html_response(conn, 200) =~ "Edit authority"
    end
  end

  describe "update authority" do
    setup [:create_authority, :create_user]

    test "redirects when data is valid", %{
      conn: conn,
      authority: authority,
      user: %{id: user_id}
    } do
      conn =
        put(conn |> fake_sign_in(user_id), Routes.authority_path(conn, :update, authority),
          authority: @update_attrs
        )

      assert redirected_to(conn) == Routes.authority_path(conn, :show, authority)

      conn = get(conn, Routes.authority_path(conn, :show, authority))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, authority: authority} do
      conn =
        put(conn |> fake_sign_in, Routes.authority_path(conn, :update, authority),
          authority: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit authority"
    end
  end

  defp create_authority(_) do
    authority = fixture(:authority)
    {:ok, authority: authority}
  end

  defp create_authority_kind(_) do
    authority_kind = fixture(:authority_kind)
    {:ok, authority_kind: authority_kind}
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
