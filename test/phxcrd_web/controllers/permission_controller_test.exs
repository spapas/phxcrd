defmodule PhxcrdWeb.PermissionControllerTest do
  use PhxcrdWeb.ConnCase

  alias Phxcrd.Auth

  @create_attrs %{name: "some name", verbose_name: "some verbose_name"}
  @update_attrs %{name: "some updated name", verbose_name: "some updated verbose_name"}
  @invalid_attrs %{name: nil, verbose_name: nil}

  def fixture(:permission) do
    {:ok, permission} = Auth.create_permission(@create_attrs)
    permission
  end

  defp fake_sign_in(conn, user_id \\ 1) do
    conn
    |> Plug.Test.init_test_session(%{})
    |> Plug.Conn.put_session(:permissions, ["superuser"])
    |> Plug.Conn.put_session(:user_signed_in?, true)
    |> Plug.Conn.put_session(:user_id, user_id)
    |> Plug.Conn.put_session(:username, "test")
  end

  describe "index" do
    test "lists all permissions", %{conn: conn} do
      conn = get(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Permissions"
    end

    test "denies access for anonymous", %{conn: conn} do
      conn = get(conn, AdminRoutes.permission_path(conn, :index))
      assert html_response(conn, 302) =~ "redirect"
    end

    test "denies access for non superuser", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> Plug.Conn.put_session(:permissions, ["admin"])
        |> Plug.Conn.put_session(:user_signed_in?, true)
        |> Plug.Conn.put_session(:user_id, 1)
        |> Plug.Conn.put_session(:username, "test")

      conn = get(conn, AdminRoutes.permission_path(conn, :index))
      assert html_response(conn, 302) =~ "redirect"
    end
  end

  describe "new permission" do
    test "renders form", %{conn: conn} do
      conn = get(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :new))
      assert html_response(conn, 200) =~ "New Permission"
    end
  end

  describe "create permission" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :create),
          permission: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == AdminRoutes.permission_path(conn, :show, id)

      conn = get(conn, AdminRoutes.permission_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Permission"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :create),
          permission: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Permission"
    end
  end

  describe "edit permission" do
    setup [:create_permission]

    test "renders form for editing chosen permission", %{conn: conn, permission: permission} do
      conn = get(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :edit, permission))
      assert html_response(conn, 200) =~ "Edit Permission"
    end
  end

  describe "update permission" do
    setup [:create_permission]

    test "redirects when data is valid", %{conn: conn, permission: permission} do
      conn =
        put(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :update, permission),
          permission: @update_attrs
        )

      assert redirected_to(conn) == AdminRoutes.permission_path(conn, :show, permission)

      conn = get(conn, AdminRoutes.permission_path(conn, :show, permission))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, permission: permission} do
      conn =
        put(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :update, permission),
          permission: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Permission"
    end
  end

  describe "delete permission" do
    setup [:create_permission]

    test "deletes chosen permission", %{conn: conn, permission: permission} do
      conn = delete(conn |> fake_sign_in, AdminRoutes.permission_path(conn, :delete, permission))
      assert redirected_to(conn) == AdminRoutes.permission_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, AdminRoutes.permission_path(conn, :show, permission))
      end
    end
  end

  defp create_permission(_) do
    permission = fixture(:permission)
    {:ok, permission: permission}
  end
end
