defmodule PhxcrdWeb.AuthorityLiveTest do
  use PhxcrdWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Phxcrd.Auth

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp fixture(:authority) do
    {:ok, authority} = Auth.create_authority(@create_attrs)
    authority
  end

  defp create_authority(_) do
    authority = fixture(:authority)
    %{authority: authority}
  end

  describe "Index" do
    setup [:create_authority]

    test "lists all authorities", %{conn: conn, authority: authority} do
      {:ok, _index_live, html} = live(conn, AdminRoutes.authority_index_path(conn, :index))

      assert html =~ "Listing Authorities"
    end

    test "saves new authority", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, AdminRoutes.authority_index_path(conn, :index))

      assert index_live |> element("a", "New Authority") |> render_click() =~
               "New Authority"

      assert_patch(index_live, AdminRoutes.authority_index_path(conn, :new))

      assert index_live
             |> form("#authority-form", authority: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#authority-form", authority: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, AdminRoutes.authority_index_path(conn, :index))

      assert html =~ "Authority created successfully"
    end

    test "updates authority in listing", %{conn: conn, authority: authority} do
      {:ok, index_live, _html} = live(conn, AdminRoutes.authority_index_path(conn, :index))

      assert index_live |> element("#authority-#{authority.id} a", "Edit") |> render_click() =~
               "Edit Authority"

      assert_patch(index_live, AdminRoutes.authority_index_path(conn, :edit, authority))

      assert index_live
             |> form("#authority-form", authority: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#authority-form", authority: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, AdminRoutes.authority_index_path(conn, :index))

      assert html =~ "Authority updated successfully"
    end

    test "deletes authority in listing", %{conn: conn, authority: authority} do
      {:ok, index_live, _html} = live(conn, AdminRoutes.authority_index_path(conn, :index))

      assert index_live |> element("#authority-#{authority.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#authority-#{authority.id}")
    end
  end

  describe "Show" do
    setup [:create_authority]

    test "displays authority", %{conn: conn, authority: authority} do
      {:ok, _show_live, html} =
        live(conn, AdminRoutes.authority_show_path(conn, :show, authority))

      assert html =~ "Show Authority"
    end

    test "updates authority within modal", %{conn: conn, authority: authority} do
      {:ok, show_live, _html} =
        live(conn, AdminRoutes.authority_show_path(conn, :show, authority))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Authority"

      assert_patch(show_live, AdminRoutes.authority_show_path(conn, :edit, authority))

      assert show_live
             |> form("#authority-form", authority: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#authority-form", authority: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, AdminRoutes.authority_show_path(conn, :show, authority))

      assert html =~ "Authority updated successfully"
    end
  end
end
