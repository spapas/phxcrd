defmodule Phxcrd.Auth.UserPermission do
  use Ecto.Schema

  alias Phxcrd.Auth.User
  alias Phxcrd.Auth.Permission

  schema "users_permissions" do
    belongs_to :users, User, foreign_key: :user_id
    belongs_to :permissions, Permission, foreign_key: :permission_id

    timestamps()
  end
end
