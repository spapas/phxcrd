defmodule PhxcrdWeb.AuthorityControllerTest do
  use PhxcrdWeb.ConnCase
  alias Phxcrd.Auth

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:authority) do
    {:ok, authority} = Auth.create_authority(@create_attrs)
    authority
  end

  describe "index" do
    test "lists all authorities", %{conn: conn} do
      conn = get(conn, Routes.authority_path(conn, :index))
      assert html_response(conn, 200) =~ "Authority list"
    end
  end

  describe "new authority" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.authority_path(conn, :new))
      assert html_response(conn, 200) =~ "New Authority"
    end
  end

  describe "create authority" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.authority_path(conn, :create), authority: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.authority_path(conn, :show, id)

      conn = get(conn, Routes.authority_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Authority"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.authority_path(conn, :create), authority: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Authority"
    end
  end

  describe "edit authority" do
    setup [:create_authority]

    test "renders form for editing chosen authority", %{conn: conn, authority: authority} do
      conn = get(conn, Routes.authority_path(conn, :edit, authority))
      assert html_response(conn, 200) =~ "Edit Authority"
    end
  end

  describe "update authority" do
    setup [:create_authority]

    test "redirects when data is valid", %{conn: conn, authority: authority} do
      conn = put(conn, Routes.authority_path(conn, :update, authority), authority: @update_attrs)
      assert redirected_to(conn) == Routes.authority_path(conn, :show, authority)

      conn = get(conn, Routes.authority_path(conn, :show, authority))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, authority: authority} do
      conn = put(conn, Routes.authority_path(conn, :update, authority), authority: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Authority"
    end
  end

  defp create_authority(_) do
    authority = fixture(:authority)
    {:ok, authority: authority}
  end
end
