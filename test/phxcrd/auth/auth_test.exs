defmodule Phxcrd.AuthTest do
  use Phxcrd.DataCase

  alias Phxcrd.Auth

  describe "authorities" do
    alias Phxcrd.Auth.Authority

    @valid_attrs %{name: "some name", authority_kind_id: nil}
    @update_attrs %{name: "some updated name", authority_kind_id: nil}
    @invalid_attrs %{name: nil}

    def authority_fixture(attrs \\ %{}) do
      {:ok, ak} = Auth.create_authority_kind(%{name: DateTime.utc_now() |> DateTime.to_string()})

      {:ok, authority} =
        Auth.create_authority(
          attrs
          |> Enum.into(@valid_attrs)
          |> Map.merge(%{authority_kind_id: ak.id})
        )

      authority
    end

    test "list_authorities/0 returns all authorities" do
      authority = authority_fixture()

      assert Auth.list_authorities() |> Enum.map(& &1.id) == [authority] |> Enum.map(& &1.id)
    end

    test "get_authority!/1 returns the authority with given id" do
      authority = authority_fixture()
      assert Auth.get_authority!(authority.id).id == authority.id
    end

    test "create_authority/1 with valid data creates a authority" do
      {:ok, ak} = Auth.create_authority_kind(%{name: "name"})

      assert {:ok, %Authority{} = authority} =
               Auth.create_authority(%{@valid_attrs | authority_kind_id: ak.id})

      assert authority.name == "some name"
    end

    test "create_authority/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_authority(@invalid_attrs)
    end

    test "update_authority/2 with valid data updates the authority" do
      authority = authority_fixture()
      {:ok, ak} = Auth.create_authority_kind(%{name: "name"})

      assert {:ok, %Authority{} = authority} =
               Auth.update_authority(authority, %{@update_attrs | authority_kind_id: ak.id})

      assert authority.name == "some updated name"
    end

    test "update_authority/2 with invalid data returns error changeset" do
      authority = authority_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_authority(authority, @invalid_attrs)
      assert authority.id == Auth.get_authority!(authority.id).id
    end

    test "delete_authority/1 deletes the authority" do
      authority = authority_fixture()
      assert {:ok, %Authority{}} = Auth.delete_authority(authority)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_authority!(authority.id) end
    end

    test "change_authority/1 returns a authority changeset" do
      authority = authority_fixture()
      assert %Ecto.Changeset{} = Auth.change_authority(authority)
    end
  end

  describe "users" do
    alias Phxcrd.Auth.User

    @valid_attrs %{
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
      username: "some username",
      last_login: DateTime.utc_now(),
      is_enabled: true
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
      username: nil,
      is_enabled: true
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Auth.list_users() |> Enum.map(& &1.id) == [user] |> Enum.map(& &1.id)
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert user.am == "some am"
      assert user.am_phxcrd == "some am_phxcrd"
      assert user.dsn == "some dsn"
      assert user.email == "some email"
      assert user.extra == "some extra"
      assert user.first_name == "some first_name"
      assert user.kind == "some kind"
      assert user.last_name == "some last_name"
      assert user.name == "some name"
      assert user.obj_cls == "some obj_cls"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Auth.update_user(user, @update_attrs)
      assert user.am == "some updated am"
      assert user.am_phxcrd == "some updated am_phxcrd"
      assert user.dsn == "some updated dsn"
      assert user.email == "some updated email"
      assert user.extra == "some updated extra"
      assert user.first_name == "some updated first_name"
      assert user.kind == "some updated kind"
      assert user.last_name == "some updated last_name"
      assert user.name == "some updated name"
      assert user.obj_cls == "some updated obj_cls"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end

  describe "permissions" do
    alias Phxcrd.Auth.Permission

    @valid_attrs %{name: "some name", verbose_name: "some verbose_name"}
    @update_attrs %{name: "some updated name", verbose_name: "some updated verbose_name"}
    @invalid_attrs %{name: nil, verbose_name: nil}

    def permission_fixture(attrs \\ %{}) do
      {:ok, permission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_permission()

      permission
    end

    test "list_permissions/0 returns all permissions" do
      permission = permission_fixture()
      assert Auth.list_permissions() == [permission]
    end

    test "get_permission!/1 returns the permission with given id" do
      permission = permission_fixture()
      assert Auth.get_permission!(permission.id) == permission
    end

    test "create_permission/1 with valid data creates a permission" do
      assert {:ok, %Permission{} = permission} = Auth.create_permission(@valid_attrs)
      assert permission.name == "some name"
      assert permission.verbose_name == "some verbose_name"
    end

    test "create_permission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_permission(@invalid_attrs)
    end

    test "update_permission/2 with valid data updates the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{} = permission} = Auth.update_permission(permission, @update_attrs)
      assert permission.name == "some updated name"
      assert permission.verbose_name == "some updated verbose_name"
    end

    test "update_permission/2 with invalid data returns error changeset" do
      permission = permission_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_permission(permission, @invalid_attrs)
      assert permission == Auth.get_permission!(permission.id)
    end

    test "delete_permission/1 deletes the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{}} = Auth.delete_permission(permission)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_permission!(permission.id) end
    end

    test "change_permission/1 returns a permission changeset" do
      permission = permission_fixture()
      assert %Ecto.Changeset{} = Auth.change_permission(permission)
    end
  end
end
