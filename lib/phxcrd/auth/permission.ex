defmodule Phxcrd.Auth.Permission do
  use Ecto.Schema
  import Ecto.Changeset
  alias Phxcrd.Auth.User
  alias Phxcrd.Auth.UserPermission

  schema "permissions" do
    field :name, :string
    field :verbose_name, :string

    many_to_many(
      :users,
      User,
      join_through: UserPermission,
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:name, :verbose_name])
    |> validate_required([:name, :verbose_name])
    |> unique_constraint(:name, message: "The name exists!")
  end
end
