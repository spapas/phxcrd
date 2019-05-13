defmodule Phxcrd.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Phxcrd.Repo

  alias Phxcrd.Auth.Authority
  alias Phxcrd.Auth.AuthorityKind
  alias Phxcrd.Auth.User
  alias Phxcrd.Auth.Permission
  # alias Phxcrd.Auth.Version

  @doc """
  Returns the list of authorities.

  ## Examples

      iex> list_authorities()
      [%Authority{}, ...]

  """
  def list_authorities do
    Repo.all(
      from a in Authority,
        join: ak in AuthorityKind,
        on: [id: a.authority_kind_id],
        preload: [authority_kind: ak]
    )
  end

  def list_authority_kinds do
    Repo.all(AuthorityKind)
  end

  @doc """
  Gets a single authority.

  Raises `Ecto.NoResultsError` if the Authority does not exist.

  ## Examples

      iex> get_authority!(123)
      %Authority{}

      iex> get_authority!(456)
      ** (Ecto.NoResultsError)

  """
  def get_authority!(id), do: Repo.get!(Authority, id) |> Repo.preload([:authority_kind, :users])

  @doc """
  Creates a authority.

  ## Examples

      iex> create_authority(%{field: value})
      {:ok, %Authority{}}

      iex> create_authority(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_authority(attrs \\ %{}) do
    %Authority{}
    |> Authority.changeset(attrs)
    |> Repo.insert()
  end

  def create_authority_kind(attrs \\ %{}) do
    %AuthorityKind{}
    |> AuthorityKind.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a authority.

  ## Examples

      iex> update_authority(authority, %{field: new_value})
      {:ok, %Authority{}}

      iex> update_authority(authority, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_authority(%Authority{} = authority, attrs) do
    users = Repo.all(from u in User, where: u.id in ^Map.get(attrs, "users", []))

    authority
    |> Repo.preload(:users)
    |> Authority.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:users, users)
    |> Repo.update()
  end

  @doc """
  Deletes a Authority.

  ## Examples

      iex> delete_authority(authority)
      {:ok, %Authority{}}

      iex> delete_authority(authority)
      {:error, %Ecto.Changeset{}}

  """
  def delete_authority(%Authority{} = authority) do
    Repo.delete(authority)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking authority changes.

  ## Examples

      iex> change_authority(authority)
      %Ecto.Changeset{source: %Authority{}}

  """
  def change_authority(%Authority{} = authority) do
    Authority.changeset(authority, %{})
  end

  alias Phxcrd.Auth.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload([:permissions])

  def get_for_db_login(username) do
    case Repo.one(from u in User, where: u.username == ^username and not is_nil(u.password_hash)) do
      nil -> {:error, "User not found"}
      user -> {:ok, user |> Repo.preload([:permissions, :authority])}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    case %User{} |> User.changeset(attrs) |> Repo.insert() do
      {:ok, user} -> {:ok, user |> Repo.preload([:permissions])}
      error -> error
    end
  end

  def create_db_user(attrs \\ %{}) do
    case %User{}
         |> User.db_user_changeset(attrs)
         |> Repo.insert() do
      {:ok, user} -> {:ok, user |> Repo.preload([:permissions])}
      error -> error
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> Repo.preload(:permissions)
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_and_perms(%User{} = user, attrs) do
    perms = Repo.all(from p in Permission, where: p.id in ^Map.get(attrs, "permissions", []))

    user
    |> Repo.preload(:permissions)
    |> User.db_user_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:permissions, perms)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Phxcrd.Auth.Permission

  @doc """
  Returns the list of permissions.

  ## Examples

      iex> list_permissions()
      [%Permission{}, ...]

  """
  def list_permissions do
    Repo.all(Permission)
  end

  @doc """
  Gets a single permission.

  Raises `Ecto.NoResultsError` if the Permission does not exist.

  ## Examples

      iex> get_permission!(123)
      %Permission{}

      iex> get_permission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_permission!(id), do: Repo.get!(Permission, id)

  @doc """
  Creates a permission.

  ## Examples

      iex> create_permission(%{field: value})
      {:ok, %Permission{}}

      iex> create_permission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a permission.

  ## Examples

      iex> update_permission(permission, %{field: new_value})
      {:ok, %Permission{}}

      iex> update_permission(permission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Permission.

  ## Examples

      iex> delete_permission(permission)
      {:ok, %Permission{}}

      iex> delete_permission(permission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking permission changes.

  ## Examples

      iex> change_permission(permission)
      %Ecto.Changeset{source: %Permission{}}

  """
  def change_permission(%Permission{} = permission) do
    Permission.changeset(permission, %{})
  end
end
