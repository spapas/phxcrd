defmodule PhxcrdWeb.UserControllerTest do
  use PhxcrdWeb.ConnCase

  alias Phxcrd.Auth

  @create_attrs %{
    am: "some am",
    am_phxcrd: "some am_phxcrd",
    dsn: "some dsn",
    email: "some email",
    extra: "some extra",
    first_name: "some first_name",
    kind: "some kind",
    last_name: "some last_name",
    name: "some name",
    obj_cls: "some obj_cls",
    username: "some username"
  }
  @update_attrs %{
    am: "some updated am",
    am_phxcrd: "some updated am_phxcrd",
    dsn: "some updated dsn",
    email: "some updated email",
    extra: "some updated extra",
    first_name: "some updated first_name",
    kind: "some updated kind",
    last_name: "some updated last_name",
    name: "some updated name",
    obj_cls: "some updated obj_cls",
    username: "some updated username"
  }
  @invalid_attrs %{
    am: nil,
    am_phxcrd: nil,
    dsn: nil,
    email: nil,
    extra: nil,
    first_name: nil,
    kind: nil,
    last_name: nil,
    name: nil,
    obj_cls: nil,
    username: nil
  }

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated am"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
